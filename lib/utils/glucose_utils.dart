
import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';
import 'constants.dart';

class GlucoseUtils {
  static Color getGlucoseColor(double value) {
    if (value < AppStrings.glucoseLowThreshold) {
      return AppColors.glucoseLow;
    } else if (value > AppStrings.glucoseHighThreshold) {
      return AppColors.glucoseHigh;
    } else {
      return AppColors.glucoseNormal;
    }
  }

  static Color getTrendColor(String trendArrow) {
    switch (trendArrow) {
      case '↑↑':
      case '↑':
        return AppColors.trendUp;
      case '↓↓':
      case '↓':
        return AppColors.trendDown;
      case '→':
      default:
        return AppColors.trendStable;
    }
  }

  static Color getRangeColor(GlucoseRange range) {
    switch (range) {
      case GlucoseRange.low:
        return AppColors.glucoseLow;
      case GlucoseRange.high:
        return AppColors.glucoseHigh;
      case GlucoseRange.normal:
      default:
        return AppColors.glucoseNormal;
    }
  }

  static String getTrendDescription(GlucoseTrend trend) {
    switch (trend) {
      case GlucoseTrend.rapidlyRising:
        return '快速上升';
      case GlucoseTrend.rising:
        return '上升';
      case GlucoseTrend.stable:
        return '穩定';
      case GlucoseTrend.falling:
        return '下降';
      case GlucoseTrend.rapidlyFalling:
        return '快速下降';
    }
  }

  static String getRangeDescription(GlucoseRange range) {
    switch (range) {
      case GlucoseRange.low:
        return '低血糖';
      case GlucoseRange.high:
        return '高血糖';
      case GlucoseRange.normal:
        return '正常範圍';
    }
  }

  static String formatTimestamp(DateTime timestamp) {
    return DateHelper.formatTimestamp(timestamp);
  }

  static String formatGlucoseValue(double value) {
    return '${value.round()} mg/dL';
  }

  static String getGlucoseStatus(double value) {
    if (value < 70) {
      return '低血糖';
    } else if (value > 180) {
      return '高血糖';
    } else {
      return '正常';
    }
  }

  static IconData getGlucoseIcon(double value) {
    if (value < 70) {
      return Icons.arrow_downward;
    } else if (value > 180) {
      return Icons.arrow_upward;
    } else {
      return Icons.check_circle;
    }
  }

  static bool isInTargetRange(double value, {double? lowTarget, double? highTarget}) {
    final low = lowTarget ?? AppStrings.glucoseLowThreshold;
    final high = highTarget ?? AppStrings.glucoseHighThreshold;
    return value >= low && value <= high;
  }

  static double calculateAverageGlucose(List<GlucoseReading> readings) {
    if (readings.isEmpty) return 0.0;
    final sum = readings.fold(0.0, (sum, reading) => sum + reading.value);
    return sum / readings.length;
  }

  static int countHighEvents(List<GlucoseReading> readings, {double? threshold}) {
    final high = threshold ?? AppStrings.glucoseHighThreshold;
    return readings.where((r) => r.value > high).length;
  }

  static int countLowEvents(List<GlucoseReading> readings, {double? threshold}) {
    final low = threshold ?? AppStrings.glucoseLowThreshold;
    return readings.where((r) => r.value < low).length;
  }

  static double calculateTimeInRange(List<GlucoseReading> readings, {double? lowTarget, double? highTarget}) {
    if (readings.isEmpty) return 0.0;

    final low = lowTarget ?? AppStrings.tirTargetMin;
    final high = highTarget ?? AppStrings.tirTargetMax;

    final inRangeCount = readings.where((r) => r.value >= low && r.value <= high).length;
    return (inRangeCount / readings.length) * 100;
  }
}