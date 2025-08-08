import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/bluetooth_service.dart';
import '../models/device_info.dart';
import '../models/glucose_reading.dart';

class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();

  // 藍牙狀態
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isScanning = false;
  bool _isConnecting = false;

  // 設備資訊
  List<BluetoothDevice> _availableDevices = [];
  BluetoothDevice? _connectedDevice;
  DeviceInfo? _deviceInfo;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;

  // 錯誤處理
  String? _errorMessage;

  // 訂閱
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<DeviceInfo>? _deviceInfoSubscription;
  StreamSubscription<GlucoseReading>? _glucoseSubscription;

  // Getters
  BluetoothAdapterState get adapterState => _adapterState;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _connectionState == BluetoothConnectionState.connected;
  bool get isBluetoothOn => _adapterState == BluetoothAdapterState.on;
  List<BluetoothDevice> get availableDevices => List.unmodifiable(_availableDevices);
  BluetoothDevice? get connectedDevice => _connectedDevice;
  DeviceInfo? get deviceInfo => _deviceInfo;
  BluetoothConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;

  BluetoothProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _bluetoothService.initialize();
      _subscribeToBluetoothEvents();
      await checkBluetoothStatus();
    } catch (e) {
      _setError('藍牙服務初始化失敗: ${e.toString()}');
    }
  }

  // 訂閱藍牙事件
  void _subscribeToBluetoothEvents() {
    // 監聽藍牙適配器狀態
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      notifyListeners();

      if (state != BluetoothAdapterState.on && _isScanning) {
        _stopScanning();
      }
    });

    // 監聽連接狀態
    _connectionStateSubscription = _bluetoothService.connectionState.listen((state) {
      _connectionState = state;

      if (state == BluetoothConnectionState.disconnected) {
        _connectedDevice = null;
        _deviceInfo = null;
      }

      notifyListeners();
    });

    // 監聽設備資訊
    _deviceInfoSubscription = _bluetoothService.deviceInfo.listen((info) {
      _deviceInfo = info;
      notifyListeners();
    });
  }

  // 檢查藍牙狀態
  Future<void> checkBluetoothStatus() async {
    try {
      _clearError();
      final state = await _bluetoothService.getBluetoothState();
      _adapterState = state;
      notifyListeners();
    } catch (e) {
      _setError('檢查藍牙狀態失敗: ${e.toString()}');
    }
  }

  // 開始掃描設備
  Future<void> startScanning({Duration? timeout}) async {
    if (!isBluetoothOn) {
      _setError('請先開啟藍牙');
      return;
    }

    if (_isScanning) {
      await stopScanning();
    }

    try {
      _isScanning = true;
      _availableDevices.clear();
      _clearError();
      notifyListeners();

      final devices = await _bluetoothService.scanForCGMDevices(timeout: timeout);
      _availableDevices = devices;

    } catch (e) {
      _setError('掃描設備失敗: ${e.toString()}');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // 停止掃描
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('停止掃描時發生錯誤: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // 連接設備
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return false;

    try {
      _isConnecting = true;
      _clearError();
      notifyListeners();

      final success = await _bluetoothService.connectToDevice(device);

      if (success) {
        _connectedDevice = device;
        _connectionState = BluetoothConnectionState.connected;

        // 停止掃描
        if (_isScanning) {
          await stopScanning();
        }
      }

      return success;
    } catch (e) {
      _setError('連接設備失敗: ${e.toString()}');
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  // 斷開設備連接
  Future<void> disconnectDevice() async {
    try {
      _clearError();
      await _bluetoothService.disconnectDevice();

      _connectedDevice = null;
      _deviceInfo = null;
      _connectionState = BluetoothConnectionState.disconnected;

      notifyListeners();
    } catch (e) {
      _setError('斷開連接失敗: ${e.toString()}');
    }
  }

  // 重新連接設備
  Future<bool> reconnectDevice() async {
    if (_connectedDevice == null) return false;

    try {
      _clearError();
      return await _bluetoothService.reconnectDevice();
    } catch (e) {
      _setError('重新連接失敗: ${e.toString()}');
      return false;
    }
  }

  // 刷新連接
  Future<void> refreshConnection() async {
    if (!isConnected) return;

    try {
      _clearError();

      // 檢查設備是否仍然連接
      if (_connectedDevice != null) {
        final deviceState = await _connectedDevice!.connectionState.first;

        if (deviceState == BluetoothConnectionState.disconnected) {
          // 嘗試重新連接
          await reconnectDevice();
        }
      }
    } catch (e) {
      _setError('刷新連接失敗: ${e.toString()}');
    }
  }

  // 獲取已配對的設備
  Future<void> loadBondedDevices() async {
    try {
      _clearError();
      final bondedDevices = await _bluetoothService.getBondedDevices();

      // 過濾出 CGM 設備
      final cgmDevices = bondedDevices.where((device) {
        final deviceName = device.platformName.toLowerCase();
        return deviceName.contains('cgm') ||
            deviceName.contains('glucose') ||
            deviceName.contains('freestyle') ||
            deviceName.contains('dexcom');
      }).toList();

      _availableDevices = cgmDevices;
      notifyListeners();
    } catch (e) {
      _setError('載入已配對設備失敗: ${e.toString()}');
    }
  }

  // 忘記設備
  Future<void> forgetDevice(BluetoothDevice device) async {
    try {
      _clearError();

      // 如果是當前連接的設備，先斷開連接
      if (_connectedDevice?.remoteId == device.remoteId) {
        await disconnectDevice();
      }

      // 從可用設備列表中移除
      _availableDevices.removeWhere((d) => d.remoteId == device.remoteId);
      notifyListeners();

    } catch (e) {
      _setError('忘記設備失敗: ${e.toString()}');
    }
  }

  // 校準血糖
  Future<bool> calibrateGlucose(double referenceValue) async {
    if (!isConnected) {
      _setError('設備未連接');
      return false;
    }

    try {
      _clearError();
      final success = await _bluetoothService.calibrateGlucose(referenceValue);

      if (!success) {
        _setError('校準失敗，設備可能不支援此功能');
      }

      return success;
    } catch (e) {
      _setError('校準失敗: ${e.toString()}');
      return false;
    }
  }

  // 獲取歷史數據
  Future<List<GlucoseReading>> getHistoricalData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!isConnected) {
      _setError('設備未連接');
      return [];
    }

    try {
      _clearError();
      return await _bluetoothService.getHistoricalData(
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      _setError('獲取歷史數據失敗: ${e.toString()}');
      return [];
    }
  }

  // 獲取連接狀態描述
  String get connectionStatusDescription {
    switch (_connectionState) {
      case BluetoothConnectionState.disconnected:
        return '未連接';
      case BluetoothConnectionState.connected:
        return '已連接';
      default:
        return '連接中...';
    }
  }

  // 獲取藍牙狀態描述
  String get bluetoothStatusDescription {
    switch (_adapterState) {
      case BluetoothAdapterState.on:
        return '藍牙已開啟';
      case BluetoothAdapterState.off:
        return '藍牙已關閉';
      case BluetoothAdapterState.turningOn:
        return '正在開啟藍牙...';
      case BluetoothAdapterState.turningOff:
        return '正在關閉藍牙...';
      case BluetoothAdapterState.unavailable:
        return '藍牙不可用';
      case BluetoothAdapterState.unauthorized:
        return '藍牙權限被拒絕';
      default:
        return '藍牙狀態未知';
    }
  }

  // 私有方法：停止掃描
  void _stopScanning() {
    _isScanning = false;
    notifyListeners();
  }

  // 設置錯誤訊息
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 清除錯誤訊息
  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _deviceInfoSubscription?.cancel();
    _glucoseSubscription?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }
}