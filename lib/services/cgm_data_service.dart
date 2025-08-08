
import 'dart:math' as math;
import '../models/glucose_reading.dart';
import '../models/food_log.dart';
import '../models/exercise_log.dart';
import '../models/insulin_log.dart';

class CGMDataService {
  // 計算血糖統計數據
  Future<Map<String, dynamic>> calculateStatistics(List<GlucoseReading> readings) async {
    if (readings.isEmpty) {
      return {
        'averageGlucose': 0.0,
        'standardDeviation': 0.0,
        'coefficientOfVariation': 0.0,
        'timeInRange': 0.0,
        'highEvents': 0,
        'lowEvents': 0,
        'totalReadings': 0,
      };
    }

    final values = readings.map((r) => r.value).toList();

    // 計算平均值
    final average = values.reduce((a, b) => a + b) / values.length;

    // 計算標準差
    final variance = values.map((v) => math.pow(v - average, 2)).reduce((a, b) => a + b) / values.length;
    final standardDeviation = math.sqrt(variance);

    // 計算變異係數
    final cv = average > 0 ? (standardDeviation / average) * 100 : 0.0;

    // 計算 TIR
    final inRangeCount = readings.where((r) => r.value >= 70 && r.value <= 180).length;
    final tir = (inRangeCount / readings.length) * 100;

    // 計算事件數
    final highEvents = readings.where((r) => r.value > 180).length;
    final lowEvents = readings.where((r) => r.value < 70).length;

    return {
      'averageGlucose': average,
      'standardDeviation': standardDeviation,
      'coefficientOfVariation': cv,
      'timeInRange': tir,
      'highEvents': highEvents,
      'lowEvents': lowEvents,
      'totalReadings': readings.length,
    };
  }

  // 匯出數據
  Future<String> exportData({
    required List<GlucoseReading> glucoseReadings,
    required List<FoodLog> foodLogs,
    required List<ExerciseLog> exerciseLogs,
    required List<InsulinLog> insulinLogs,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? dataTypes,
  }) async {
    // 暫時返回成功訊息
    return '數據匯出功能開發中...';
  }

  // 分析血糖趨勢
  Future<Map<String, dynamic>> analyzeTrends(List<GlucoseReading> readings) async {
    // 暫時返回空分析
    return {
      'trend': 'stable',
      'prediction': 0.0,
      'confidence': 0.0,
    };
  }
}