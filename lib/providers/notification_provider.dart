import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../providers/settings_provider.dart'; // 添加這個 import

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService.instance;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _notificationsEnabled = true;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get notificationsEnabled => _notificationsEnabled;

  NotificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();
    await loadNotifications();
  }

  Future<void> loadNotifications() async {
    // 這裡應該從數據庫載入通知
    // 暫時使用模擬數據
    _notifications = [
      AppNotification(
        id: '1',
        title: '歡迎使用 Xenia',
        body: '開始您的血糖管理之旅',
        type: NotificationType.info,
        timestamp: DateTime.now(),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: '血糖提醒',
        body: '請記得檢查您的血糖數值',
        type: NotificationType.reminder,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '3',
        title: '設備連接',
        body: 'CGM 設備已成功連接',
        type: NotificationType.deviceAlert,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];
    _updateUnreadCount();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }
}