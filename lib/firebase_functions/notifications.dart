import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_notifications/main.dart';
import 'package:firebase_notifications/views/notificationpage.dart';
import 'package:firebase_notifications/views/orderpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

bool responded = false;

class CustomAudioPlayer {
  static AudioPlayer player = AudioPlayer();

  static void playRingtone() {
    log("Playing ringtone");
    player.play(AssetSource('noti.wav')); // Play the ringtone
    player.onPlayerComplete.listen((event) {
      log("Ringtone completed");
      player.play(AssetSource('noti.wav'));
    });
    player.onPlayerStateChanged.listen((event) {
        
        log(player.state.toString());
        
    });
  }

  static void stopRingtone() {
    player.stop();
    print("turned off Audio");
  }
}

void showIncomingOrderScreen(String orderDetails) {
  log("Showing incoming order screen");
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrderScreen(orderDetails: orderDetails),
  ));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  CustomAudioPlayer.playRingtone();
  // showIncomingOrderScreen(message.notification?.body ?? "New Order");
  log("Handling a background message: ${message.messageId}");
  log("Handling a background message: ${message.notification?.title}");
  log("Handling a background message: ${message.notification?.body}");
  log("Handling a background message: ${message.data}");
}

class FirebaseCM {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
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

    initPushNotification();
    initLocalNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    CustomAudioPlayer.stopRingtone();
    if (message == null) return;
    navigatorKey.currentState
        ?.pushNamed(NotificationPage.route, arguments: message);
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      CustomAudioPlayer.playRingtone();
      // showIncomingOrderScreen(message.notification?.body ?? "New Order");
      final notification = message.notification;
      if (notification == null) return;
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              androidChannel.id, androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@mipmap/ic_launcher',
              priority: Priority.high,
              importance: Importance.high,
              fullScreenIntent: true),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) async {
        final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
        handleMessage(message);
      },
    );

    final platform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(androidChannel);
  }
}
