import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cambridge_customer/models/address.dart';
import 'package:cambridge_customer/ordersScreens/address_design_widget.dart';
import 'package:cambridge_customer/ordersScreens/status_banner_widget.dart';
import '../global/global.dart';

class OrderDetailsScreen extends StatefulWidget {
  String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderStatus = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (c, AsyncSnapshot dataSnapshot) {
            Map? orderDataMap;
            if (dataSnapshot.hasData) {
              orderDataMap = dataSnapshot.data.data() as Map<String, dynamic>;
              orderStatus = orderDataMap["status"].toString();

              return Column(
                children: [
                  // Status Banner - Keeping it on top for a clear indication
                  StatusBanner(
                    status: orderDataMap["isSuccess"],
                    orderStatus: orderStatus,
                  ),

                  // Spacing for better visual separation
                  SizedBox(height: 30),

                  // Total Amount with a more stylish font and some padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "₹ " + orderDataMap["totalAmount"].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Order ID styled with a more subtle color and padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Order ID: " + orderDataMap["orderId"].toString(),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Order Time with a subtle style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Ordered on: " + DateFormat("dd MMMM, yyyy - hh:mm aa")
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(orderDataMap["orderTime"]))),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const Divider(
                    thickness: 1,
                    color: Colors.white54,
                  ),

                  // Order Status Image (Visual representation based on the status)
                  orderStatus == "ended"
                      ? Image.asset("images/cambridge_1.jpg")
                      : Image.asset("images/cambridge_1.jpg"),

                  const Divider(
                    thickness: 1,
                    color: Colors.white54,
                  ),

                  // Shipping Details Section (with a clean and organized presentation)
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(sharedPreferences!.getString("uid"))
                        .collection("userAddress")
                        .doc(orderDataMap["addressID"])
                        .get(),
                    builder: (c, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return AddressDesign(
                          model: Address.fromJson(
                              snapshot.data.data() as Map<String, dynamic>),
                          orderStatus: orderStatus,
                          orderId: widget.orderID,
                          sellerId: orderDataMap!["sellerUID"],
                          orderByUser: orderDataMap["orderBy"],
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No data exists.",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
                  "No data exists.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
