import 'package:cambridge_customer/sellersScreens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cambridge_customer/assistantMethods/address_changer.dart';
import 'package:cambridge_customer/assistantMethods/cart_item_counter.dart';
import 'package:cambridge_customer/assistantMethods/total_amount.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cambridge_customer/global/global.dart';
import 'package:cambridge_customer/splashScreen/my_splash_screen.dart';
import 'package:cambridge_customer/push_notifications/push_notifications_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences and Firebase
  sharedPreferences = await SharedPreferences.getInstance();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PushNotificationsSystem pushNotificationsSystem;

  @override
  void initState() {
    super.initState();
    pushNotificationsSystem = PushNotificationsSystem();
    setupPushNotifications();
  }

  Future<void> setupPushNotifications() async {
    try {
      await pushNotificationsSystem.initialize(context); // Initialize push notifications
    } catch (e) {
      print("Error initializing push notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => CartItemCounter()),
        ChangeNotifierProvider(create: (c) => TotalAmount()),
        ChangeNotifierProvider(create: (c) => AddressChanger()),
      ],
      child: MaterialApp(
        title: 'Cambridge',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
