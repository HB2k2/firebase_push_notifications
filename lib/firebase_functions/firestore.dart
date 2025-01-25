import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseDB {
  static Future<void> addUniqueId() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('Token: $fcmToken');
    try {
      FirebaseFirestore.instance
          .collection("UserUniqueIds")
          .doc(DateTime.now().toString())
          .set({
        "User Details": FieldValue.arrayUnion([fcmToken]),
      }, SetOptions(merge: true));
    } catch (e) {
      log("error in uploadingUserUniqueId ${e.toString()}");
    }
  }
}
