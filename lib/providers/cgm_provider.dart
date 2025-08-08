import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';
import '../models/device_info.dart';
import '../services/database_service.dart';
import '../services/bluetooth_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class CGMProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final BluetoothService _bluetoothService = BluetoothService();
  final NotificationService _notificationService = NotificationService.instance;

  // 狀態變數
  bool _isLoading = false;
  String? _errorMessage;
  List<GlucoseReading> _glucoseReadings = [];
  GlucoseReading? _latestReading;
  DeviceInfo? _connectedDevice;

  // 統計數據
  double _averageGlucose = 0.0;
  double _timeInRange = 0.0;
  double _coefficientOfVariation = 0.0;
  int _highGlucoseEvents = 0;
  int _lowGlucoseEvents = 0;

  // 訂閱
  StreamSubscription<GlucoseReading>? _glucoseSubscription;
  StreamSubscription<DeviceInfo>? _deviceSubscription;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GlucoseReading> get glucoseReadings => List.unmodifiable(_glucoseReadings);
  GlucoseReading? get latestReading => _latestReading;
  DeviceInfo? get connectedDevice => _connectedDevice;

  // 統計數據 Getters
  double get averageGlucose => _averageGlucose;
  double get timeInRange => _timeInRange;
  double get coefficientOfVariation => _coefficientOfVariation;
  int get highGlucoseEvents => _highGlucoseEvents;
  int get lowGlucoseEvents => _lowGlucoseEvents;

  CGMProvider() {
    _initialize();
  }

  // 初始化
  Future<void> _initialize() async {
    try {
      await _databaseService.initialize();
      _subscribeToBluetoothData();
      await loadGlucoseData();
    } catch (e) {
      _setError('初始化失敗: ${e.toString()}');
    }
  }

  // 訂閱藍牙數據
  void _subscribeToBluetoothData() {
    // 監聽血糖讀數
    _glucoseSubscription = _bluetoothService.glucoseReadings.listen(
      _handleNewGlucoseReading,
      onError: (error) {
        _setError('血糖數據接收失敗: ${error.toString()}');
      },
    );

    // 監聽設備資訊
    _deviceSubscription = _bluetoothService.deviceInfo.listen(
          (deviceInfo) {
        _connectedDevice = deviceInfo;
        notifyListeners();
      },
      onError: (error) {
        print('設備資訊接收失敗: $error');
      },
    );
  }

  // 處理新的血糖讀數
  Future<void> _handleNewGlucoseReading(GlucoseReading reading) async {
    try {
      // 儲存到本地資料庫
      await _databaseService.insertGlucoseReading(reading);

      // 更新內存數據
      _glucoseReadings.insert(0, reading);
      _latestReading = reading;

      // 限制內存中的數據量
      if (_glucoseReadings.length > 1000) {
        _glucoseReadings = _glucoseReadings.take(1000).toList();
      }

      // 檢查警報條件
      await _checkGlucoseAlerts(reading);

      // 重新計算統計數據
      await _calculateStatistics();

      notifyListeners();
    } catch (e) {
      _setError('處理血糖數據失敗: ${e.toString()}');
    }
  }

  // 檢查血糖警報
  Future<void> _checkGlucoseAlerts(GlucoseReading reading) async {
    try {
      // 高血糖警報
      if (reading.value > AppStrings.glucoseHighThreshold) {
        await _notificationService.showGlucoseAlert(
          reading: reading,
          title: AppStrings.notificationGlucoseHigh,
          body: '當前血糖 ${reading.value.round()} mg/dL，超過安全範圍',
          isHighAlert: true,
        );
      }
      // 低血糖警報
      else if (reading.value < AppStrings.glucoseLowThreshold) {
        await _notificationService.showGlucoseAlert(
          reading: reading,
          title: AppStrings.notificationGlucoseLow,
          body: '當前血糖 ${reading.value.round()} mg/dL，請立即處理',
          isHighAlert: false,
        );
      }
    } catch (e) {
      print('發送血糖警報失敗: $e');
    }
  }

  // 載入血糖數據
  Future<void> loadGlucoseData({int? hours, int? limit}) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();

      final readings = await _databaseService.getGlucoseReadings(
        hours: hours,
        limit: limit ?? 288, // 預設載入24小時數據 (每5分鐘一筆)
      );

      _glucoseReadings = readings;
      _latestReading = readings.isNotEmpty ? readings.first : null;

      await _calculateStatistics();
    } catch (e) {
      _setError('載入血糖數據失敗: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 計算統計數據
  Future<void> _calculateStatistics({int? hours}) async {
    if (_glucoseReadings.isEmpty) {
      _resetStatistics();
      return;
    }

    try {
      List<GlucoseReading> dataForCalculation;

      if (hours != null) {
        final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
        dataForCalculation = _glucoseReadings
            .where((r) => r.timestamp.isAfter(cutoffTime))
            .toList();
      } else {
        dataForCalculation = _glucoseReadings;
      }

      if (dataForCalculation.isEmpty) {
        _resetStatistics();
        return;
      }

      final values = dataForCalculation.map((r) => r.value).toList();

      // 計算平均血糖
      _averageGlucose = values.reduce((a, b) => a + b) / values.length;

      // 計算目標範圍內時間 (TIR)
      final inRangeCount = dataForCalculation
          .where((r) => r.value >= AppStrings.tirTargetMin && r.value <= AppStrings.tirTargetMax)
          .length;
      _timeInRange = (inRangeCount / dataForCalculation.length) * 100;

      // 計算變異係數 (CV)
      final variance = values
          .map((v) => math.pow(v - _averageGlucose, 2))
          .reduce((a, b) => a + b) / values.length;
      final standardDeviation = math.sqrt(variance);
      _coefficientOfVariation = _averageGlucose > 0
          ? (standardDeviation / _averageGlucose) * 100
          : 0.0;

      // 計算高低血糖事件
      _highGlucoseEvents = dataForCalculation
          .where((r) => r.value > AppStrings.glucoseHighThreshold)
          .length;
      _lowGlucoseEvents = dataForCalculation
          .where((r) => r.value < AppStrings.glucoseLowThreshold)
          .length;

    } catch (e) {
      print('計算統計數據失敗: $e');
      _resetStatistics();
    }
  }

  // 重置統計數據
  void _resetStatistics() {
    _averageGlucose = 0.0;
    _timeInRange = 0.0;
    _coefficientOfVariation = 0.0;
    _highGlucoseEvents = 0;
    _lowGlucoseEvents = 0;
  }

  // 計算指定時間範圍的 TIR
  double calculateTIR({int? hours, double? lowTarget, double? highTarget}) {
    if (_glucoseReadings.isEmpty) return 0.0;

    List<GlucoseReading> dataForCalculation;

    if (hours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      dataForCalculation = _glucoseReadings
          .where((r) => r.timestamp.isAfter(cutoffTime))
          .toList();
    } else {
      dataForCalculation = _glucoseReadings;
    }

    if (dataForCalculation.isEmpty) return 0.0;

    final low = lowTarget ?? AppStrings.tirTargetMin;
    final high = highTarget ?? AppStrings.tirTargetMax;

    final inRangeCount = dataForCalculation
        .where((r) => r.value >= low && r.value <= high)
        .length;

    return (inRangeCount / dataForCalculation.length) * 100;
  }

  // 計算平均血糖
  double calculateAverageGlucose({int? hours}) {
    if (_glucoseReadings.isEmpty) return 0.0;

    List<GlucoseReading> dataForCalculation;

    if (hours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      dataForCalculation = _glucoseReadings
          .where((r) => r.timestamp.isAfter(cutoffTime))
          .toList();
    } else {
      dataForCalculation = _glucoseReadings;
    }

    if (dataForCalculation.isEmpty) return 0.0;

    final values = dataForCalculation.map((r) => r.value).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  // 計算變異係數
  double calculateCoefficientOfVariation({int? hours}) {
    if (_glucoseReadings.isEmpty) return 0.0;

    final average = calculateAverageGlucose(hours: hours);
    if (average == 0) return 0.0;

    List<GlucoseReading> dataForCalculation;

    if (hours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      dataForCalculation = _glucoseReadings
          .where((r) => r.timestamp.isAfter(cutoffTime))
          .toList();
    } else {
      dataForCalculation = _glucoseReadings;
    }

    if (dataForCalculation.isEmpty) return 0.0;

    final values = dataForCalculation.map((r) => r.value).toList();
    final variance = values
        .map((v) => math.pow(v - average, 2))
        .reduce((a, b) => a + b) / values.length;
    final standardDeviation = math.sqrt(variance);

    return (standardDeviation / average) * 100;
  }

  // 獲取高血糖事件
  List<GlucoseReading> getHighGlucoseEvents({int? hours, double? threshold}) {
    final high = threshold ?? AppStrings.glucoseHighThreshold;

    List<GlucoseReading> dataForCalculation;

    if (hours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      dataForCalculation = _glucoseReadings
          .where((r) => r.timestamp.isAfter(cutoffTime))
          .toList();
    } else {
      dataForCalculation = _glucoseReadings;
    }

    return dataForCalculation.where((r) => r.value > high).toList();
  }

  // 獲取低血糖事件
  List<GlucoseReading> getLowGlucoseEvents({int? hours, double? threshold}) {
    final low = threshold ?? AppStrings.glucoseLowThreshold;

    List<GlucoseReading> dataForCalculation;

    if (hours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      dataForCalculation = _glucoseReadings
          .where((r) => r.timestamp.isAfter(cutoffTime))
          .toList();
    } else {
      dataForCalculation = _glucoseReadings;
    }

    return dataForCalculation.where((r) => r.value < low).toList();
  }

  // 手動添加血糖讀數（用於測試或手動輸入）
  Future<void> addManualGlucoseReading({
    required double value,
    required DateTime timestamp,
    GlucoseTrend trend = GlucoseTrend.stable,
    String? notes,
  }) async {
    try {
      final reading = GlucoseReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        value: value,
        timestamp: timestamp,
        trend: trend,
        deviceId: 'manual',
        isCalibrated: true,
        metadata: notes != null ? {'notes': notes} : null,
      );

      await _databaseService.insertGlucoseReading(reading);
      await loadGlucoseData(); // 重新載入數據

    } catch (e) {
      _setError('添加血糖記錄失敗: ${e.toString()}');
    }
  }

  // 校準血糖（如果設備支援）
  Future<bool> calibrateGlucose(double referenceValue) async {
    try {
      _clearError();

      final success = await _bluetoothService.calibrateGlucose(referenceValue);

      if (success) {
        // 重新載入數據以獲取校準後的讀數
        await loadGlucoseData();
      }

      return success;
    } catch (e) {
      _setError('血糖校準失敗: ${e.toString()}');
      return false;
    }
  }

  // 同步歷史數據
  Future<void> syncHistoricalData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();

      final historicalData = await _bluetoothService.getHistoricalData(
        startTime: startTime,
        endTime: endTime,
      );

      if (historicalData.isNotEmpty) {
        await _databaseService.insertGlucoseReadings(historicalData);
        await loadGlucoseData();
      }

    } catch (e) {
      _setError('同步歷史數據失敗: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清除所有數據
  Future<void> clearAllData() async {
    try {
      await _databaseService.clearAllData();
      _glucoseReadings.clear();
      _latestReading = null;
      _resetStatistics();
      notifyListeners();
    } catch (e) {
      _setError('清除數據失敗: ${e.toString()}');
    }
  }

  // 設置錯誤訊息
  void _setError(String message) {
    _errorMessage = message;
    print('CGMProvider Error: $message');
  }

  // 清除錯誤訊息
  void _clearError() {
    _errorMessage = null;
  }

  // 清除錯誤訊息（公開方法）
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _glucoseSubscription?.cancel();
    _deviceSubscription?.cancel();
    super.dispose();
  }
}