import 'package:firebase_notifications/firebase_functions/notifications.dart';
import 'package:flutter/material.dart';

import 'package:firebase_notifications/views/homepage.dart';
import 'package:firebase_notifications/views/notificationpage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FirebaseCM().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: "/",
      routes: {
        NotificationPage.route: (context) => const NotificationPage(),
        '/': (context) => const HomePage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
