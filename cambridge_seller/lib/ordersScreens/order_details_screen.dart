import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cambridge_seller/ordersScreens/status_banner_widget.dart';
import '../global/global.dart';
import '../models/address.dart';
import 'address_design_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderStatus = "";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (dataSnapshot.hasError || !dataSnapshot.hasData || dataSnapshot.data == null) {
              return const Center(
                child: Text(
                  "Order data could not be loaded.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            final orderDataMap = dataSnapshot.data!.data() as Map<String, dynamic>;
            orderStatus = orderDataMap["status"].toString();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add spacing at the top for status banner
                SizedBox(height: screenHeight * 0.02),

                // Status Banner with responsive padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: StatusBanner(
                    status: orderDataMap["isSuccess"],
                    orderStatus: orderStatus,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Total Amount
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    "₹${orderDataMap["totalAmount"]}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // Order ID
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    "Order ID: ${orderDataMap["orderId"]}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // Order Time
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    "Ordered on: ${DateFormat("dd MMMM, yyyy - hh:mm aa").format(DateTime.fromMillisecondsSinceEpoch(int.parse(orderDataMap["orderTime"])))}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),

                const Divider(thickness: 1, color: Colors.pinkAccent),

                // Order Status Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Image.asset(
                    orderStatus != "ended" ? "images/packing.jpg" : "images/delivered.jpg",
                    width: screenWidth * 0.9,
                  ),
                ),

                const Divider(thickness: 1, color: Colors.pinkAccent),

                // Shipping Details Section Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    "Shipping Details",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // Address Section
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(orderDataMap["orderBy"])
                      .collection("userAddress")
                      .doc(orderDataMap["addressID"])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text(
                          "Address data could not be loaded.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          border: Border.all(color: Colors.pinkAccent, width: 1),
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: AddressDesign(
                          model: Address.fromJson(snapshot.data!.data() as Map<String, dynamic>),
                          orderStatus: orderStatus,
                          orderId: widget.orderID,
                          sellerId: orderDataMap["sellerUID"],
                          orderByUser: orderDataMap["orderBy"],
                          totalAmount: orderDataMap["totalAmount"].toString(),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: screenHeight * 0.02),
              ],
            );
          },
        ),
      ),
    );
  }
}
