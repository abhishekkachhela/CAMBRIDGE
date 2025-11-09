import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cambridge_customer/global/global.dart';
import 'package:cambridge_customer/sellersScreens/home_screen.dart';

class MockPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String sellerUID;
  final String addressID;
  final String? itemID;
  final int quantity;
  final VoidCallback? onPaymentSuccess;  // Added callback

  MockPaymentScreen({
    required this.totalAmount,
    required this.sellerUID,
    required this.addressID,
    this.itemID,
    this.quantity = 1,
    this.onPaymentSuccess,  // Added to constructor
  });

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  bool _isProcessing = true;
  String _statusMessage = "Processing Payment...";

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<bool> updateInventory() async {
    try {
      if (widget.itemID != null) {
        // Get current quantity
        DocumentSnapshot itemDoc = await FirebaseFirestore.instance
            .collection('items')
            .doc(widget.itemID)
            .get();

        if (!itemDoc.exists) {
          throw 'Item not found';
        }

        int currentQuantity = int.parse(itemDoc.get('quantityInStock').toString());

        if (currentQuantity < widget.quantity) {
          throw 'Insufficient stock';
        }

        // Update quantity
        await FirebaseFirestore.instance
            .collection('items')
            .doc(widget.itemID)
            .update({
          'quantityInStock': (currentQuantity - widget.quantity).toString(),
        });
      }
      return true;
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
      return false;
    }
  }

  Future<void> _processPayment() async {
    try {
      setState(() {
        _statusMessage = "Processing Payment...";
      });

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Update inventory first
      setState(() {
        _statusMessage = "Updating Inventory...";
      });

      bool inventoryUpdated = await updateInventory();
      if (!inventoryUpdated) {
        throw 'Failed to update inventory';
      }

      setState(() {
        _statusMessage = "Saving Order Details...";
      });

      // Save order details
      await orderDetails();

      // Call the success callback if provided
      widget.onPaymentSuccess?.call();  // Added callback invocation

      Fluttertoast.showToast(msg: "Order has been placed successfully.");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (error) {
      setState(() {
        _isProcessing = false;
      });
      Fluttertoast.showToast(msg: "Payment failed: ${error.toString()}");
      Navigator.pop(context);
    }
  }

  Future<void> orderDetails() async {
    Map<String, dynamic> orderDetailsMap = {
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Paid Online",
      "orderTime": orderId,
      "orderId": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "status": "normal",
      "itemID": widget.itemID,
      "quantity": widget.quantity,
    };

    // Save for user
    await saveOrderDetailsForUser(orderDetailsMap);

    // Save for seller
    await saveOrderDetailsForSeller(orderDetailsMap);

    // Clear cart and send notification
    await cartMethods.clearCart(context);
    await sendPushNotificationToSeller(widget.sellerUID, orderId);
  }

  Future<void> sendPushNotificationToSeller(String sellerUID, String orderId) async {
    try {
      final url = 'https://your-api-url/send-notification';
      await http.post(Uri.parse(url), body: {
        'sellerUID': sellerUID,
        'orderId': orderId,
        'message': 'You have a new order!',
      });
    } catch (e) {
      // Log error but don't stop the order process
      print("Failed to send notification: $e");
    }
  }

  Future<void> saveOrderDetailsForUser(Map<String, dynamic> orderDetailsMap) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(orderDetailsMap);
  }

  Future<void> saveOrderDetailsForSeller(Map<String, dynamic> orderDetailsMap) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(orderDetailsMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            if (!_isProcessing)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}