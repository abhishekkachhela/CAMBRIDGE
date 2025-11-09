import 'package:flutter/material.dart';
import 'package:cambridge_seller/splashScreen/my_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'global/global.dart';
import 'package:cambridge_seller/push_notifications/push_notifications_system.dart';

/// Handles background FCM messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background Message Received: ${message.notification?.title}");
}

/// Main entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  print("Firebase initialized");

  // Handle background messaging
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  print("Background messaging handler set up");

  // Initialize shared preferences
  sharedPreferences = await SharedPreferences.getInstance();
  print("SharedPreferences initialized: ${sharedPreferences?.getStringList("userCart")}");

  // Log and get token
  await getToken();

  // Start application
  runApp(const MyApp());
}

/// Retrieves Firebase Cloud Messaging token
Future<void> getToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Authorization status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permissions granted');
    }

    String? token = await messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await sharedPreferences?.setString("fcm_token", token);
    } else {
      print("Failed to retrieve FCM token.");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      handleIncomingNotification(message);
    });
  } catch (e) {
    print("Error during token retrieval: $e");
  }
}

/// Handle notifications in the foreground
void handleIncomingNotification(RemoteMessage message) {
  if (message.notification != null) {
    print(
        "Foreground Notification: Title: ${message.notification?.title}, Body: ${message.notification?.body}"
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellers App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home:  MySplashScreen(),
    );
  }
}
