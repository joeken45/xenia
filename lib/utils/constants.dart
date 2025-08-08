import 'package:flutter/material.dart';

class AppColors {
  // 主色調
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  // 次要色調
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color secondaryDark = Color(0xFF004BA0);

  // 狀態色調
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 血糖範圍色調
  static const Color glucoseHigh = Color(0xFFE53E3E);
  static const Color glucoseNormal = Color(0xFF38A169);
  static const Color glucoseLow = Color(0xFFD69E2E);

  // 背景色調
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  // 文字色調
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // 趨勢色調
  static const Color trendUp = Color(0xFFE53E3E);
  static const Color trendDown = Color(0xFF3182CE);
  static const Color trendStable = Color(0xFF38A169);
}

class AppSizes {
  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
}

class AppStrings {
  // 應用程式資訊
  static const String appName = 'Xenia';
  static const String appVersion = '1.0.0';

  // 血糖範圍
  static const String glucoseUnit = 'mg/dL';
  static const double glucoseLowThreshold = 70.0;
  static const double glucoseHighThreshold = 180.0;
  static const double glucoseTargetMin = 70.0;
  static const double glucoseTargetMax = 180.0;

  // TIR 目標範圍
  static const double tirTargetMin = 70.0;
  static const double tirTargetMax = 180.0;

  // 錯誤訊息
  static const String errorNetwork = '網路連線錯誤，請檢查網路設定';
  static const String errorBluetooth = '藍牙連線失敗，請重試';
  static const String errorAuthentication = '驗證失敗，請重新登入';
  static const String errorDataLoad = '資料載入失敗，請重試';

  // 成功訊息
  static const String successLogin = '登入成功';
  static const String successRegister = '註冊成功';
  static const String successPasswordReset = '密碼重設郵件已發送';
  static const String successDataSaved = '資料已儲存';

  // 通知類型
  static const String notificationGlucoseHigh = '高血糖警告';
  static const String notificationGlucoseLow = '低血糖警告';
  static const String notificationDeviceDisconnected = '設備已斷線';
  static const String notificationMealReminder = '進食提醒';
  static const String notificationExerciseReminder = '運動提醒';
}

class AppDurations {
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  static const Duration refreshInterval = Duration(minutes: 1);
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration reconnectInterval = Duration(seconds: 30);
}

class BluetoothConstants {
  // CGM 服務 UUID (範例，實際需要根據設備文檔)
  static const String cgmServiceUuid = '1808';
  static const String glucoseMeasurementCharacteristic = '2A18';
  static const String glucoseFeatureCharacteristic = '2A51';
  static const String recordAccessControlPointCharacteristic = '2A52';

  // 掃描設定
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // 設備名稱過濾 (根據實際 CGM 設備調整)
  static const List<String> deviceNameFilters = [
    'CGM',
    'Glucose',
    'FreeStyle',
    'Dexcom',
    'Guardian',
  ];
}

class DatabaseConstants {
  static const String databaseName = 'xenia_app.db';
  static const int databaseVersion = 1;

  // 表格名稱
  static const String tableGlucoseReadings = 'glucose_readings';
  static const String tableFoodLogs = 'food_logs';
  static const String tableExerciseLogs = 'exercise_logs';
  static const String tableInsulinLogs = 'insulin_logs';
  static const String tableDeviceInfo = 'device_info';
  static const String tableNotifications = 'notifications';

  // 數據保留時間 (天)
  static const int dataRetentionDays = 90;
}

class ValidationRules {
  // Email 正則表達式
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // 密碼規則
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 32;

  // 手機號碼正則表達式 (台灣)
  static const String phonePattern = r'^09\d{8}$';

  // 血糖值範圍
  static const double glucoseMinValue = 20.0;
  static const double glucoseMaxValue = 600.0;

  // 胰島素劑量範圍
  static const double insulinMinDose = 0.1;
  static const double insulinMaxDose = 100.0;

  // 碳水化合物範圍 (克)
  static const double carbsMinValue = 0.0;
  static const double carbsMaxValue = 500.0;
}

class NotificationChannels {
  static const String glucoseAlertsId = 'glucose_alerts';
  static const String glucoseAlertsName = '血糖警報';
  static const String glucoseAlertsDescription = '高低血糖警報通知';

  static const String deviceStatusId = 'device_status';
  static const String deviceStatusName = '設備狀態';
  static const String deviceStatusDescription = '設備連線狀態通知';

  static const String remindersId = 'reminders';
  static const String remindersName = '提醒事項';
  static const String remindersDescription = '進食、運動等提醒通知';
}

class FileConstants {
  static const String exportDirectory = 'Xenia_Reports';
  static const String exportFilePrefix = 'Xenia_Report_';
  static const String exportFileExtension = '.pdf';

  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];

  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
}

class APIConstants {
  // Firebase 集合名稱
  static const String usersCollection = 'users';
  static const String glucoseReadingsCollection = 'glucose_readings';
  static const String foodLogsCollection = 'food_logs';
  static const String exerciseLogsCollection = 'exercise_logs';
  static const String insulinLogsCollection = 'insulin_logs';
  static const String devicesCollection = 'devices';

  // API 端點 (如果有自定義後端)
  static const String baseUrl = 'https://api.xeniaapp.com';
  static const String apiVersion = 'v1';

  // 請求超時時間
  static const Duration requestTimeout = Duration(seconds: 30);

  // 重試設定
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}