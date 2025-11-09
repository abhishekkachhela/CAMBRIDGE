import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';

class PushNotificationsSystem {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    // Request permissions for iOS (and Android if needed)
    NotificationSettings settings = await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Generate the FCM device token
      await generateDeviceRecognitionToken();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(context, message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Method to generate and print the FCM token
  Future<void> generateDeviceRecognitionToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('Device FCM Token: $token');
      await storeTokenInFirestore(token);
    }
  }

  // Method to store the FCM token in Firestore
  Future<void> storeTokenInFirestore(String token) async {
    String? uid = sharedPreferences?.getString("uid");
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set({"fcmToken": token}, SetOptions(merge: true));
    }
  }

  // Handle incoming messages (foreground and background)
  void _handleMessage(BuildContext context, RemoteMessage message) {
    if (message.notification != null) {
      _showNotificationDialog(context, message.notification!);
    }
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Additional processing for background notifications if needed
  }

  // Show notification dialog for foreground messages
  void _showNotificationDialog(BuildContext context, RemoteNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title ?? 'Notification'),
        content: Text(notification.body ?? 'No message body'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
