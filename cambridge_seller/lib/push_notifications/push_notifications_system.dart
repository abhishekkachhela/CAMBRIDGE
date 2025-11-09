import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../global/global.dart';
import 'package:flutter/material.dart';

class PushNotificationsSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Notifications arrived/received
  Future<void> whenNotificationReceived(BuildContext context) async {
    // 1. Terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        _handleMessage(remoteMessage, context);
      }
    });

    // 2. Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        _handleMessage(remoteMessage, context);
      }
    });

    // 3. Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        _handleMessage(remoteMessage, context);
      }
    });
  }

  // Function to handle the received message
  void _handleMessage(RemoteMessage message, BuildContext context) {
    if (message.notification != null) {
      print("Notification received: ${message.notification?.title}");
      print("Notification body: ${message.notification?.body}");

      // Show a dialog with notification details
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message.notification!.title ?? 'No Title'),
            content: Text(message.notification!.body ?? 'No Body'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      print("No notification payload.");
    }
  }

  // Device recognition token
  Future<void> generateDeviceRecognitionToken() async {
    String? registrationDeviceToken = await messaging.getToken();
    String? uid = sharedPreferences!.getString("uid");
    print('Retrieved UID: $uid'); // Debug log

    if (uid != null) {
      DocumentReference sellerDoc = FirebaseFirestore.instance.collection("sellers").doc(uid);
      DocumentSnapshot sellerSnapshot = await sellerDoc.get();

      print('Seller document exists: ${sellerSnapshot.exists}'); // Debug log
      if (sellerSnapshot.exists) {
        await sellerDoc.update({"sellerDeviceToken": registrationDeviceToken});
        messaging.subscribeToTopic("allSellers");
        messaging.subscribeToTopic("allUsers");
      } else {
        print('Seller document does not exist. Please check your uid.');
      }
    } else {
      print('Seller UID is null. Seller may not be logged in.');
    }
  }
}
