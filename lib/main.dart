import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_notifications/firebase_functions/firestore.dart';
import 'package:firebase_notifications/firebase_functions/notifications.dart';
import 'package:flutter/material.dart';

import 'package:firebase_notifications/views/homepage.dart';
import 'package:firebase_notifications/views/notificationpage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseCM().initNotifications();
  FirebaseDB.addUniqueId();
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
        '/notificationpage': (context) => const NotificationPage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
