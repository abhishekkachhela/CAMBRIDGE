import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cambridge_customer/global/global.dart';
import '../sellersScreens/home_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  String? addressID;
  double? totalAmount;
  String? sellerUID;

  PlaceOrderScreen({this.addressID, this.totalAmount, this.sellerUID});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  orderDetails() {
    saveOrderDetailsForUser({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Cash On Delivery",
      "orderTime": orderId,
      "orderId": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "status": "normal",
    }).whenComplete(() {
      saveOrderDetailsForSeller({
        "addressID": widget.addressID,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": sharedPreferences!.getStringList("userCart"),
        "paymentDetails": "Cash On Delivery",
        "orderTime": orderId,
        "orderId": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "status": "normal",
      }).whenComplete(() {
        cartMethods.clearCart(context);

        // Send push notification to the seller
        sendPushNotificationToSeller(widget.sellerUID!, orderId);

        Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));

        orderId = "";
      });
    });
  }

  Future<void> sendPushNotificationToSeller(String sellerUID, String orderId) async {
    final url = 'https://your-api-url/send-notification';
    await http.post(Uri.parse(url), body: {
      'sellerUID': sellerUID,
      'orderId': orderId,
      'message': 'You have a new order!',
    });
  }

  saveOrderDetailsForUser(Map<String, dynamic> orderDetailsMap) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(orderDetailsMap);
  }

  saveOrderDetailsForSeller(Map<String, dynamic> orderDetailsMap) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(orderDetailsMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/cambridge_1.jpg"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                orderDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text("Place Order Now"),
            ),
          ],
        ),
      ),
    );
  }
}
