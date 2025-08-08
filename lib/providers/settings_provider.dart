
class SettingsProvider extends ChangeNotifier {
  // 血糖警報設定
  double _highGlucoseThreshold = 180.0;
  double _lowGlucoseThreshold = 70.0;
  bool _enableAlarms = true;

  // 應用程式設定
  String _language = 'zh_TW';
  bool _darkMode = false;
  String _glucoseUnit = 'mg/dL';

  // 通知設定
  bool _glucoseAlertsEnabled = true;
  bool _deviceAlertsEnabled = true;
  bool _reminderAlertsEnabled = true;

  // Getters
  double get highGlucoseThreshold => _highGlucoseThreshold;
  double get lowGlucoseThreshold => _lowGlucoseThreshold;
  bool get enableAlarms => _enableAlarms;
  String get language => _language;
  bool get darkMode => _darkMode;
  String get glucoseUnit => _glucoseUnit;
  bool get glucoseAlertsEnabled => _glucoseAlertsEnabled;
  bool get deviceAlertsEnabled => _deviceAlertsEnabled;
  bool get reminderAlertsEnabled => _reminderAlertsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // 從 SharedPreferences 載入設定
    // 暫時使用預設值
    notifyListeners();
  }

  Future<void> setHighGlucoseThreshold(double value) async {
    _highGlucoseThreshold = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLowGlucoseThreshold(double value) async {
    _lowGlucoseThreshold = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEnableAlarms(bool value) async {
    _enableAlarms = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setGlucoseAlertsEnabled(bool value) async {
    _glucoseAlertsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    // 保存到 SharedPreferences
    // 暫時為空實現
  }
}

// 通知數據模型
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  info,
  warning,
  error,
  glucoseAlert,
  deviceAlert,
  reminder,
}