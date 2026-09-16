import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';

@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize(AuthNotifier authNotifier) async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    const androidChannel = AndroidNotificationChannel(
      'edunova_high_importance',
      'EduNova Notifications',
      description: 'Important notifications from EduNova',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null) {
      await authNotifier.registerDeviceToken(_fcmToken!);
    }

    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      authNotifier.registerDeviceToken(token);
    });

    await subscribeToTopic('all');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (_) {}
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (_) {}
  }

  Future<void> subscribeToBatch(int batchId) async {
    await subscribeToTopic('batch_$batchId');
  }

  Future<void> unsubscribeFromBatch(int batchId) async {
    await unsubscribeFromTopic('batch_$batchId');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final linkType = data['type'] ?? '';
    final linkId = data['id'] ?? '';

    String? payload;
    if (linkType.isNotEmpty) {
      payload = '$linkType:$linkId';
    }

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      payload: payload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'edunova_high_importance',
          'EduNova Notifications',
          channelDescription: 'Important notifications from EduNova',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('type')) {
      _navigateFromData(data['type'], data['id']);
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split(':');
    if (parts.length == 2) {
      _navigateFromData(parts[0], parts[1]);
    }
  }

  void _navigateFromData(String? type, String? id) {
    if (type == null || type.isEmpty) return;
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    switch (type) {
      case 'exam':
        context.push('/exam-detail', extra: {'id': int.tryParse(id ?? '') ?? 0});
        break;
      case 'course':
        context.push('/class-detail', extra: {'id': int.tryParse(id ?? '') ?? 0});
        break;
      case 'article':
        context.push('/articles');
        break;
      case 'lesson':
        context.push('/home');
        break;
      case 'calendar':
        context.push('/home');
        break;
      case 'doubt':
        context.push('/home');
        break;
    }
  }
}
