import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../models/address.dart';
import '../splashScreen/my_splash_screen.dart';

class AddressDesign extends StatelessWidget {
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;
  final String? totalAmount;

  AddressDesign({
    this.model,
    this.orderStatus,
    this.orderId,
    this.sellerId,
    this.orderByUser,
    this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: Shipping Details
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Shipping Details:',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),

        // Name and Phone Number
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Row(
                children: [
                  const Text(
                    "Name: ",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      model?.name ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Phone Number
              Row(
                children: [
                  const Text(
                    "Phone: ",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    model?.phoneNumber ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Address
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text.rich(
            TextSpan(
              text: "Address: ",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
              children: [
                TextSpan(
                  text: model?.completeAddress ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
        ),

        const SizedBox(height: 20),

        // Action Button
        GestureDetector(
          onTap: () {
            if (orderStatus == "normal") {
              // Update earnings
              FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(sharedPreferences!.getString("uid"))
                  .update({
                "earnings": (double.parse(previousEarning)) + (double.parse(totalAmount!)),
              }).whenComplete(() {
                // Change order status to shifted
                FirebaseFirestore.instance
                    .collection("orders")
                    .doc(orderId)
                    .update({"status": "shifted"}).whenComplete(() {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(orderByUser)
                      .collection("orders")
                      .doc(orderId)
                      .update({"status": "shifted"}).whenComplete(() {
                    // Notify user of the update
                    Fluttertoast.showToast(msg: "Confirmed Successfully.");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MySplashScreen()),
                    );
                  });
                });
              });
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MySplashScreen()));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              width: double.infinity,
              height: 60,
              child: Center(
                child: Text(
                  orderStatus == "ended"
                      ? "Go Back"
                      : orderStatus == "shifted"
                      ? "Go Back"
                      : orderStatus == "normal"
                      ? "Parcel Packed & Shifted to Nearest PickUp Point. Click to Confirm"
                      : "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
