import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cambridge_customer/placeOrderScreen/place_order_screen.dart';
import 'package:cambridge_customer/models/address.dart';
import 'package:cambridge_customer/assistantMethods/address_changer.dart';
import 'package:provider/provider.dart';

class AddressDesignWidget extends StatefulWidget {
  final Address? addressModel;
  final int? index;
  final int? value;
  final String? addressID;
  final double totalAmount; // Updated to non-nullable
  final String? sellerId;
  final VoidCallback? onEditPressed;
  final VoidCallback? onSelectPressed;

  AddressDesignWidget({
    this.addressModel,
    this.index,
    this.value,
    this.addressID,
    required this.totalAmount, // Ensure totalAmount is required
    this.sellerId,
    this.onEditPressed,
    this.onSelectPressed,
  });

  @override
  State<AddressDesignWidget> createState() => _AddressDesignWidgetState();
}

class _AddressDesignWidgetState extends State<AddressDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      child: Column(
        children: [
          // Address info
          Row(
            children: [
              Radio(
                groupValue: widget.index,
                value: widget.value!,
                activeColor: Colors.pink,
                onChanged: (val) {
                  Provider.of<AddressChanger>(context, listen: false)
                      .showSelectedAddress(val);
                  if (widget.onSelectPressed != null) {
                    widget.onSelectPressed!();
                  }
                },
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            const Text(
                              "Name: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.addressModel!.name.toString()),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              "Phone Number: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.addressModel!.phoneNumber.toString()),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              "Full Address: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.addressModel!.completeAddress
                                .toString()),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Proceed to Place Order button, only visible if the address is selected
          widget.value == Provider.of<AddressChanger>(context).count
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("Proceed"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                if (widget.addressModel!.name != null &&
                    widget.addressModel!.phoneNumber != null &&
                    widget.addressModel!.completeAddress != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => PlaceOrderScreen(
                        addressID: widget.addressID,
                        totalAmount: widget.totalAmount, // No issue now
                        sellerUID: widget.sellerId,
                      ),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Please select a valid address",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
            ),
          )
              : Container(),

          // Button for editing the address
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("Edit Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                if (widget.onEditPressed != null) {
                  widget.onEditPressed!();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
