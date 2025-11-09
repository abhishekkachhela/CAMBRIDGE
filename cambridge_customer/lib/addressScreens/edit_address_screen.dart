import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cambridge_customer/models/address.dart';

import '../global/global.dart';

class EditAddressScreen extends StatefulWidget {
  final Address currentAddress;
  final String addressID;

  EditAddressScreen({required this.currentAddress, required this.addressID});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _completeAddressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentAddress.name);
    _phoneNumberController = TextEditingController(text: widget.currentAddress.phoneNumber);
    _completeAddressController = TextEditingController(text: widget.currentAddress.completeAddress);
  }

  void saveUpdatedAddress() async {
    // Get the updated address data
    Map<String, dynamic> updatedAddress = {
      "name": _nameController.text.trim(),
      "phoneNumber": _phoneNumberController.text.trim(),
      "completeAddress": _completeAddressController.text.trim(),
    };

    // Update the address in Firebase
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("userAddress")
        .doc(widget.addressID)
        .update(updatedAddress)
        .then((_) {
      print("Address updated successfully.");
    }).catchError((error) {
      print("Failed to update address: $error");
    });

    // After saving, go back to the previous screen
    Navigator.pop(context, updatedAddress);  // Pass the updated address back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Address"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: _completeAddressController,
              decoration: const InputDecoration(labelText: "Complete Address"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUpdatedAddress,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
