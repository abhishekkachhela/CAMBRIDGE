import 'package:cambridge_customer/global/global.dart';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cambridge_customer/assistantMethods/cart_methods.dart';
import 'package:cambridge_customer/widgets/appbar_cart_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/items.dart';
import 'package:cambridge_customer/payment/mock_payment_screen.dart';
import 'package:cambridge_customer/itemsScreens/inventory_servie.dart';

class ItemsDetailsScreen extends StatefulWidget {
  final Items? model;

  const ItemsDetailsScreen({Key? key, this.model}) : super(key: key);

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  int counterLimit = 1;
  bool isProcessing = false;

  // Check if item is out of stock
  bool get isOutOfStock {
    final int availableQuantity = int.tryParse(widget.model?.quantityInStock ?? '0') ?? 0;
    return availableQuantity <= 0;
  }

  // Check if item is low in stock
  bool get isLowStock {
    final int availableQuantity = int.tryParse(widget.model?.quantityInStock ?? '0') ?? 0;
    return availableQuantity > 0 && availableQuantity <= 3;
  }



  // Size availability display widget
  Widget buildSizesDisplay() {
    final List<String> allSizes = ['S', 'M', 'L', 'XL', 'XXL'];
    List<String> availableSizes = (widget.model?.sizesAvailable ?? '').split(',')
        .map((size) => size.trim())
        .where((size) => size.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Sizes:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allSizes.map((size) {
            bool isAvailable = availableSizes.contains(size);

            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isAvailable ? Colors.grey : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isAvailable ? Colors.white : Colors.grey.shade100,
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Stock status widget
  Widget buildStockStatus() {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text(
              "Out of Stock",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (isLowStock) {
      final int availableQuantity = int.tryParse(widget.model?.quantityInStock ?? '0') ?? 0;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(
              availableQuantity <= 2
                  ? "Only $availableQuantity left in stock!"
                  : "Very few left!",
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final int availableQuantity = int.tryParse(widget.model?.quantityInStock ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithCartBadge(
        sellerUID: widget.model!.sellerUID.toString(),
      ),
      floatingActionButton: !isOutOfStock ? FloatingActionButton.extended(
        onPressed: () async {
          if (counterLimit == 0) {
            Fluttertoast.showToast(msg: "Please select a quantity before adding to cart.");
            return;
          }

          // Check stock availability before adding to cart

          List<String> itemsIDsList = cartMethods.separateItemIDsFromUserCartList();

          if (itemsIDsList.contains(widget.model!.itemID)) {
            Fluttertoast.showToast(msg: "Item is already in Cart.");
          } else {
            cartMethods.addItemToCart(
              widget.model!.itemID.toString(),
              counterLimit,
              context,
            );
          }
        },
        label: const Text("Add to Cart", style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.black),
        backgroundColor: Colors.red,
      ) : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: ColorFiltered(
                      colorFilter: isOutOfStock
                          ? const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ])
                          : const ColorFilter.matrix([
                        1, 0, 0, 0, 0,
                        0, 1, 0, 0, 0,
                        0, 0, 1, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: Image.network(
                        widget.model!.thumbnailUrl.toString(),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isOutOfStock)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock Status
              buildStockStatus(),

              // Quantity Selector (only show if in stock)
              if (!isOutOfStock) Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CartStepperInt(
                    count: counterLimit,
                    size: 50,
                    didChangeCount: (value) {
                      if (value < 0) {
                        Fluttertoast.showToast(msg: "The quantity cannot be less than 0");
                        return;
                      }

                      if (value > availableQuantity) {
                        Fluttertoast.showToast(
                            msg: "Cannot exceed available quantity ($availableQuantity)");
                        return;
                      }

                      setState(() {
                        counterLimit = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "${widget.model!.itemTitle}:",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                widget.model!.itemInfo.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.model!.longDescription.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Sizes
              if (widget.model?.sizesAvailable?.isNotEmpty ?? false)
                buildSizesDisplay(),
              const SizedBox(height: 20),

              Text(
                "₹${widget.model!.price}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.green,
                ),
              ),
              const Divider(
                height: 32,
                thickness: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}