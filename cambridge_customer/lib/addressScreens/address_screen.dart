import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cambridge_customer/addressScreens/address_design_widget.dart';
import 'package:cambridge_customer/addressScreens/save_new_address_screen.dart';
import 'package:cambridge_customer/addressScreens/edit_address_screen.dart';
import 'package:cambridge_customer/assistantMethods/address_changer.dart';
import 'package:cambridge_customer/global/global.dart';
import 'package:cambridge_customer/models/address.dart';
import 'package:cambridge_customer/payment/mock_payment_screen.dart';

class AddressScreen extends StatefulWidget {
  final String? sellerUID;
  final double? totalAmount;

  AddressScreen({this.sellerUID, this.totalAmount});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? selectedAddressID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.redAccent,
                Colors.white54,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "Cambridge",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => SaveNewAddressScreen(
                sellerUID: widget.sellerUID,
                totalAmount: widget.totalAmount ?? 0.0,
              ),
            ),
          );
        },
        label: const Text("Add New Address"),
        icon: const Icon(
          Icons.add_location,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Consumer<AddressChanger>(builder: (context, address, c) {
            return Flexible(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(sharedPreferences!.getString("uid"))
                    .collection("userAddress")
                    .snapshots(),
                builder: (context, AsyncSnapshot dataSnapshot) {
                  if (dataSnapshot.hasData) {
                    if (dataSnapshot.data.docs.length > 0) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return AddressDesignWidget(
                            addressModel: Address.fromJson(
                              dataSnapshot.data.docs[index].data()
                              as Map<String, dynamic>,
                            ),
                            index: address.count,
                            value: index,
                            addressID: dataSnapshot.data.docs[index].id,
                            totalAmount: widget.totalAmount ?? 0.0,
                            sellerId: widget.sellerUID ?? "",
                            onSelectPressed: () {
                              setState(() {
                                selectedAddressID =
                                    dataSnapshot.data.docs[index].id;
                              });
                            },
                            onEditPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditAddressScreen(
                                    currentAddress: Address.fromJson(
                                      dataSnapshot.data.docs[index].data()
                                      as Map<String, dynamic>,
                                    ),
                                    addressID: dataSnapshot.data.docs[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        itemCount: dataSnapshot.data.docs.length,
                      );
                    } else {
                      return const Center(
                        child: Text("No addresses available."),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            );
          }),
          // Proceed to Payment button, visible only when an address is selected
          if (selectedAddressID != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedAddressID != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MockPaymentScreen(
                          totalAmount: widget.totalAmount ?? 0.0,
                          sellerUID: widget.sellerUID ?? "",
                          addressID: selectedAddressID!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select an address.")),
                    );
                  }
                },
                child: const Text("Proceed to Payment"),
              ),
            ),
        ],
      ),
    );
  }
}
