import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/glucose_reading.dart';
import '../utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  String? _fcmToken;

  // 初始化通知服務
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 初始化本地通知
      await _initializeLocalNotifications();

      // 初始化 Firebase 通知
      await _initializeFirebaseMessaging();

      // 請求通知權限
      await _requestPermissions();

      _isInitialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Failed to initialize notification service: $e');
    }
  }

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 創建通知頻道 (Android)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  // 創建通知頻道 (Android)
  Future<void> _createNotificationChannels() async {
    // 血糖警報頻道
    const glucoseAlertsChannel = AndroidNotificationChannel(
      NotificationChannels.glucoseAlertsId,
      NotificationChannels.glucoseAlertsName,
      description: NotificationChannels.glucoseAlertsDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    // 設備狀態頻道
    const deviceStatusChannel = AndroidNotificationChannel(
      NotificationChannels.deviceStatusId,
      NotificationChannels.deviceStatusName,
      description: NotificationChannels.deviceStatusDescription,
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
    );

    // 提醒頻道
    const remindersChannel = AndroidNotificationChannel(
      NotificationChannels.remindersId,
      NotificationChannels.remindersName,
      description: NotificationChannels.remindersDescription,
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(glucoseAlertsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deviceStatusChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(remindersChannel);
  }

  // 初始化 Firebase 通知
  Future<void> _initializeFirebaseMessaging() async {
    // 獲取 FCM Token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // 監聽 Token 變化
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      print('FCM Token refreshed: $token');
    });

    // 處理前台訊息
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 處理背景訊息點擊
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // 處理應用程式從終止狀態啟動的訊息
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessageTap(initialMessage);
    }
  }

  // 請求通知權限
  Future<bool> _requestPermissions() async {
    // 請求本地通知權限
    if (Platform.isAndroid) {
      final androidPermissions = [
        Permission.notification,
        Permission.vibration,
      ];

      final statuses = await androidPermissions.request();
      final allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        print('Some Android notification permissions were denied');
      }

      return allGranted;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    return false;
  }

  // 發送血糖警報
  Future<void> showGlucoseAlert({
    required GlucoseReading reading,
    required String title,
    required String body,
    bool isHighAlert = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.glucoseAlertsId,
      NotificationChannels.glucoseAlertsName,
      channelDescription: NotificationChannels.glucoseAlertsDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: isHighAlert ? 'glucose_high' : 'glucose_low',
      color: isHighAlert ? AppColors.glucoseHigh : AppColors.glucoseLow,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('glucose_alert'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      ticker: title,
      autoCancel: false, // 需要用戶手動清除
      ongoing: false,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true, // 重要警報全螢幕顯示
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'glucose_alert.aiff',
      badgeNumber: 1,
      categoryIdentifier: 'glucose_alert',
      threadIdentifier: 'glucose_alerts',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      reading.value.hashCode, // 使用血糖值作為 ID
      title,
      body,
      notificationDetails,
      payload: 'glucose_alert:${reading.id}',
    );
  }

  // 發送設備狀態通知
  Future<void> showDeviceStatusNotification({
    required String title,
    required String body,
    bool isError = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.deviceStatusId,
      NotificationChannels.deviceStatusName,
      channelDescription: NotificationChannels.deviceStatusDescription,
      importance: isError ? Importance.high : Importance.defaultImportance,
      priority: isError ? Priority.high : Priority.defaultPriority,
      icon: 'bluetooth_connected',
      color: isError ? AppColors.error : AppColors.info,
      playSound: isError,
      enableVibration: isError,
      autoCancel: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'device_status',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // 簡化 ID
      title,
      body,
      notificationDetails,
      payload: 'device_status',
    );
  }

  // 發送提醒通知
  Future<void> showReminderNotification({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.remindersId,
      NotificationChannels.remindersName,
      channelDescription: NotificationChannels.remindersDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
      color: AppColors.primary,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'reminders',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
      payload: 'reminder:$type',
    );
  }

  // 排程通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = NotificationChannels.remindersId,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
      color: AppColors.primary,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(scheduledTime, TZ.local),
      notificationDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 取消通知
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // 獲取待處理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // 處理前台 Firebase 訊息
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    // 將 Firebase 訊息轉換為本地通知
    await _showFirebaseMessageAsLocalNotification(message);
  }

  // 處理背景訊息點擊
  void _handleBackgroundMessageTap(RemoteMessage message) {
    print('Background message tapped: ${message.messageId}');

    // 處理訊息數據，導航到相應頁面
    final data = message.data;
    if (data.containsKey('page')) {
      // 可以使用 Navigation Service 或全域導航器導航到指定頁面
      print('Navigate to: ${data['page']}');
    }
  }

  // 將 Firebase 訊息顯示為本地通知
  Future<void> _showFirebaseMessageAsLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'firebase_messages',
      'Firebase 訊息',
      channelDescription: '來自伺服器的推播訊息',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
      color: AppColors.primary,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'Xenia',
      notification.body ?? '',
      notificationDetails,
      payload: 'firebase:${message.messageId}',
    );
  }

  // 處理通知點擊
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');

    final payload = response.payload;
    if (payload == null) return;

    // 解析 payload 並處理相應動作
    final parts = payload.split(':');
    final type = parts.first;

    switch (type) {
      case 'glucose_alert':
      // 導航到血糖詳情頁面
        _handleGlucoseAlertTap(parts.length > 1 ? parts[1] : '');
        break;
      case 'device_status':
      // 導航到設備設定頁面
        _handleDeviceStatusTap();
        break;
      case 'reminder':
      // 導航到相應提醒頁面
        _handleReminderTap(parts.length > 1 ? parts[1] : '');
        break;
      case 'firebase':
      // 處理 Firebase 訊息
        _handleFirebaseMessageTap(parts.length > 1 ? parts[1] : '');
        break;
    }
  }

  // 處理血糖警報點擊
  void _handleGlucoseAlertTap(String readingId) {
    // 使用 Navigation Service 或 Event Bus 通知 App 導航
    print('Handle glucose alert tap for reading: $readingId');
  }

  // 處理設備狀態通知點擊
  void _handleDeviceStatusTap() {
    print('Handle device status notification tap');
  }

  // 處理提醒通知點擊
  void _handleReminderTap(String reminderType) {
    print('Handle reminder notification tap: $reminderType');
  }

  // 處理 Firebase 訊息點擊
  void _handleFirebaseMessageTap(String messageId) {
    print('Handle Firebase message tap: $messageId');
  }

  // 獲取 FCM Token
  String? get fcmToken => _fcmToken;

  // 訂閱主題
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // 取消訂閱主題
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // 檢查通知權限狀態
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  // 開啟通知設定
  Future<void> openNotificationSettings() async {
    if (Platform.isAndroid) {
      await openAppSettings();
    } else if (Platform.isIOS) {
      await openAppSettings();
    }
  }

  // 輔助方法：獲取頻道名稱
  String _getChannelName(String channelId) {
    switch (channelId) {
      case NotificationChannels.glucoseAlertsId:
        return NotificationChannels.glucoseAlertsName;
      case NotificationChannels.deviceStatusId:
        return NotificationChannels.deviceStatusName;
      case NotificationChannels.remindersId:
        return NotificationChannels.remindersName;
      default:
        return 'Xenia 通知';
    }
  }

  // 輔助方法：獲取頻道描述
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case NotificationChannels.glucoseAlertsId:
        return NotificationChannels.glucoseAlertsDescription;
      case NotificationChannels.deviceStatusId:
        return NotificationChannels.deviceStatusDescription;
      case NotificationChannels.remindersId:
        return NotificationChannels.remindersDescription;
      default:
        return 'Xenia 應用程式通知';
    }
  }

  // 清理資源
  void dispose() {
    // 清理訂閱和資源
  }
}

// 需要添加到 pubspec.yaml 的時區支援
import 'package:timezone/timezone.dart' as TZ;
import 'package:timezone/data/latest.dart' as TZ;