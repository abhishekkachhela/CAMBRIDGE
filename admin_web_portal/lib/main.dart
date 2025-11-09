import 'package:admin_web_portal/authentication/login_screen.dart';
import 'package:admin_web_portal/homeScreen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the provided options for Web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDwaLQkyyYnt5V3q3i2ceA-rgj2vdV1SQA",
      authDomain: "cambridge-customer.firebaseapp.com",
      projectId: "cambridge-customer",
      storageBucket: "cambridge-customer.appspot.com",
      messagingSenderId: "739914322353",
      appId: "1:739914322353:web:0361197c15b3fec0352d90",
      measurementId: "G-N4RP3M5KZR",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Web Portal',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser != null ? HomeScreen() : LoginScreen(),
    );
  }
}
