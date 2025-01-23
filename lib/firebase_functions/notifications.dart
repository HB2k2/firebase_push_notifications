import 'dart:convert';
import 'dart:developer';

import 'package:firebase_notifications/main.dart';
import 'package:firebase_notifications/views/notificationpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  log("Handling a background message: ${message.notification?.title}");
  log("Handling a background message: ${message.notification?.body}");
  log("Handling a background message: ${message.data}");
}

class FirebaseCM {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static void permissionRequest() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    final fcmToken = await messaging.getToken();
    log('Token: $fcmToken');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    initPushNotification();
    initLocalNotifications();
  }

  static void handleNavigation(RemoteMessage? message) {
    log("--->message:$message");
    if (message == null) return;

    navigatorKey.currentState
        ?.pushNamed(NotificationPage.route, arguments: message);
  }

  static Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleNavigation);
    FirebaseMessaging.onMessageOpenedApp.listen(handleNavigation);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    messageHandling();
  }

  static void messageHandling() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (notification != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );

        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        log("2.$payload at ${DateTime.now()}");
        handleNavigation;
      },
      onDidReceiveBackgroundNotificationResponse: (payload) async {
        log("2.$payload");
        final messageData = jsonDecode(payload.toString());
        handleNavigation(RemoteMessage.fromMap(messageData));
      },
    );

    final platform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(androidChannel);
  }
}