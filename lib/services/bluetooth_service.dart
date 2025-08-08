import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/glucose_reading.dart';
import '../models/device_info.dart';
import '../utils/constants.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _glucoseCharacteristic;
  BluetoothCharacteristic? _notificationCharacteristic;

  final StreamController<GlucoseReading> _glucoseStreamController = StreamController<GlucoseReading>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionStateController = StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<DeviceInfo> _deviceInfoController = StreamController<DeviceInfo>.broadcast();

  // Getters
  Stream<GlucoseReading> get glucoseReadings => _glucoseStreamController.stream;
  Stream<BluetoothConnectionState> get connectionState => _connectionStateController.stream;
  Stream<DeviceInfo> get deviceInfo => _deviceInfoController.stream;

  bool get isConnected => _connectedDevice != null;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // 初始化藍牙服務
  Future<void> initialize() async {
    try {
      // 檢查藍牙權限
      await _checkBluetoothPermissions();

      // 監聽藍牙狀態
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        print('Bluetooth adapter state: $state');
      });
    } catch (e) {
      print('Bluetooth initialization failed: $e');
      rethrow;
    }
  }

  // 檢查並請求藍牙權限
  Future<bool> _checkBluetoothPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    return statuses.values.every((status) =>
    status == PermissionStatus.granted ||
        status == PermissionStatus.limited);
  }

  // 掃描 CGM 設備
  Future<List<BluetoothDevice>> scanForCGMDevices({Duration? timeout}) async {
    try {
      // 檢查藍牙是否開啟
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception('此設備不支援藍牙');
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw Exception('請開啟藍牙');
      }

      // 停止之前的掃描
      await FlutterBluePlus.stopScan();

      final List<BluetoothDevice> cgmDevices = [];

      // 開始掃描
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;
          final deviceName = device.platformName.toLowerCase();

          // 檢查是否為 CGM 設備
          if (_isCGMDevice(deviceName, result.advertisementData)) {
            if (!cgmDevices.any((d) => d.remoteId == device.remoteId)) {
              cgmDevices.add(device);
            }
          }
        }
      });

      // 啟動掃描
      await FlutterBluePlus.startScan(
        timeout: timeout ?? BluetoothConstants.scanTimeout,
        withServices: [Guid(BluetoothConstants.cgmServiceUuid)],
      );

      // 等待掃描完成
      await Future.delayed(timeout ?? BluetoothConstants.scanTimeout);

      return cgmDevices;
    } catch (e) {
      print('Scan failed: $e');
      throw Exception('掃描 CGM 設備失敗: ${e.toString()}');
    }
  }

  // 連接設備
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      // 斷開之前的連接
      if (_connectedDevice != null) {
        await disconnectDevice();
      }

      print('Connecting to device: ${device.platformName}');

      // 連接設備
      await device.connect(
        timeout: BluetoothConstants.connectionTimeout,
        autoConnect: false,
      );

      // 監聽連接狀態
      device.connectionState.listen((BluetoothConnectionState state) {
        _connectionStateController.add(state);

        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
          _glucoseCharacteristic = null;
          _notificationCharacteristic = null;
        }
      });

      _connectedDevice = device;

      // 發現服務
      await _discoverServices(device);

      // 獲取設備資訊
      await _getDeviceInfo(device);

      // 啟用通知
      await _enableNotifications();

      print('Successfully connected to ${device.platformName}');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      _connectedDevice = null;
      throw Exception('連接設備失敗: ${e.toString()}');
    }
  }

  // 發現服務和特徵
  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().contains(BluetoothConstants.cgmServiceUuid.toLowerCase())) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            final charUuid = characteristic.uuid.toString().toLowerCase();

            // 血糖測量特徵
            if (charUuid.contains(BluetoothConstants.glucoseMeasurementCharacteristic.toLowerCase())) {
              _glucoseCharacteristic = characteristic;
              print('Found glucose measurement characteristic');
            }

            // 通知特徵
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              _notificationCharacteristic = characteristic;
              print('Found notification characteristic');
            }
          }
        }
      }

      if (_glucoseCharacteristic == null) {
        throw Exception('找不到血糖測量特徵');
      }
    } catch (e) {
      throw Exception('發現服務失敗: ${e.toString()}');
    }
  }

  // 啟用通知
  Future<void> _enableNotifications() async {
    try {
      if (_notificationCharacteristic != null) {
        await _notificationCharacteristic!.setNotifyValue(true);

        // 監聽數據
        _notificationCharacteristic!.lastValueStream.listen((value) {
          _handleReceivedData(value);
        });

        print('Notifications enabled');
      }
    } catch (e) {
      print('Enable notifications failed: $e');
    }
  }

  // 處理接收到的數據
  void _handleReceivedData(List<int> data) {
    try {
      // 解析血糖數據（這裡需要根據具體 CGM 設備的協議進行解析）
      final glucoseReading = _parseGlucoseData(data);
      if (glucoseReading != null) {
        _glucoseStreamController.add(glucoseReading);
      }
    } catch (e) {
      print('Parse glucose data failed: $e');
    }
  }

  // 解析血糖數據（示例實現，需要根據實際設備協議調整）
  GlucoseReading? _parseGlucoseData(List<int> data) {
    try {
      if (data.length < 8) return null;

      // 示例解析邏輯（需要根據實際 CGM 設備協議修改）
      final timestamp = DateTime.now();
      final value = ByteData.sublistView(Uint8List.fromList(data), 0, 4).getFloat32(0, Endian.little);
      final trendValue = data[4];

      GlucoseTrend trend;
      if (trendValue >= 3) {
        trend = GlucoseTrend.rapidlyRising;
      } else if (trendValue >= 2) {
        trend = GlucoseTrend.rising;
      } else if (trendValue >= -1) {
        trend = GlucoseTrend.stable;
      } else if (trendValue >= -2) {
        trend = GlucoseTrend.falling;
      } else {
        trend = GlucoseTrend.rapidlyFalling;
      }

      return GlucoseReading(
        id: '${timestamp.millisecondsSinceEpoch}',
        value: value,
        timestamp: timestamp,
        trend: trend,
        deviceId: _connectedDevice?.remoteId.toString() ?? '',
        isCalibrated: true,
      );
    } catch (e) {
      print('Parse glucose data error: $e');
      return null;
    }
  }

  // 獲取設備資訊
  Future<void> _getDeviceInfo(BluetoothDevice device) async {
    try {
      final deviceInfo = DeviceInfo(
        deviceId: device.remoteId.toString(),
        serialNumber: device.platformName,
        firmwareVersion: '1.0.0', // 實際應該從設備讀取
        hardwareVersion: '1.0', // 實際應該從設備讀取
        lastConnected: DateTime.now(),
        batteryLevel: 85, // 實際應該從設備讀取
        isConnected: true,
        sensorSerialNumber: 'SN123456', // 實際應該從設備讀取
        sensorExpiryDate: DateTime.now().add(const Duration(days: 14)),
      );

      _deviceInfoController.add(deviceInfo);
    } catch (e) {
      print('Get device info failed: $e');
    }
  }

  // 斷開設備連接
  Future<void> disconnectDevice() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _glucoseCharacteristic = null;
        _notificationCharacteristic = null;
        print('Device disconnected');
      }
    } catch (e) {
      print('Disconnect failed: $e');
    }
  }

  // 檢查設備是否為 CGM
  bool _isCGMDevice(String deviceName, AdvertisementData advertisementData) {
    // 檢查設備名稱
    for (String filter in BluetoothConstants.deviceNameFilters) {
      if (deviceName.contains(filter.toLowerCase())) {
        return true;
      }
    }

    // 檢查廣告數據中的服務 UUID
    for (String serviceId in advertisementData.serviceUuids) {
      if (serviceId.toLowerCase().contains(BluetoothConstants.cgmServiceUuid.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  // 重新連接設備
  Future<bool> reconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.connect();
        await _discoverServices(_connectedDevice!);
        await _enableNotifications();
        return true;
      } catch (e) {
        print('Reconnect failed: $e');
        return false;
      }
    }
    return false;
  }

  // 獲取藍牙狀態
  Future<BluetoothAdapterState> getBluetoothState() async {
    return await FlutterBluePlus.adapterState.first;
  }

  // 開啟藍牙（需要用戶手動操作）
  Future<void> enableBluetooth() async {
    if (await FlutterBluePlus.isSupported) {
      await FlutterBluePlus.turnOn();
    }
  }

  // 獲取已配對的設備
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await FlutterBluePlus.bondedDevices;
    } catch (e) {
      print('Get bonded devices failed: $e');
      return [];
    }
  }

  // 讀取特定特徵值
  Future<List<int>?> readCharacteristic(BluetoothCharacteristic characteristic) async {
    try {
      return await characteristic.read();
    } catch (e) {
      print('Read characteristic failed: $e');
      return null;
    }
  }

  // 寫入特定特徵值
  Future<bool> writeCharacteristic(BluetoothCharacteristic characteristic, List<int> value) async {
    try {
      await characteristic.write(value);
      return true;
    } catch (e) {
      print('Write characteristic failed: $e');
      return false;
    }
  }

  // 校準血糖讀數（如果設備支持）
  Future<bool> calibrateGlucose(double referenceValue) async {
    try {
      if (_glucoseCharacteristic != null) {
        // 構建校準指令（需要根據具體設備協議）
        final calibrationData = ByteData(4);
        calibrationData.setFloat32(0, referenceValue, Endian.little);

        return await writeCharacteristic(_glucoseCharacteristic!, calibrationData.buffer.asUint8List());
      }
      return false;
    } catch (e) {
      print('Calibrate glucose failed: $e');
      return false;
    }
  }

  // 獲取歷史數據（如果設備支持）
  Future<List<GlucoseReading>> getHistoricalData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final List<GlucoseReading> historicalData = [];

      if (_glucoseCharacteristic != null) {
        // 這裡需要根據具體設備協議實現歷史數據獲取
        // 示例：發送歷史數據請求命令

        // 暫時返回空列表
        return historicalData;
      }

      return [];
    } catch (e) {
      print('Get historical data failed: $e');
      return [];
    }
  }

  // 清理資源
  void dispose() {
    _glucoseStreamController.close();
    _connectionStateController.close();
    _deviceInfoController.close();
  }
}