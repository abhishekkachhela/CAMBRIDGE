import 'package:cambridge_seller/itemsScreens/edit_item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cambridge_seller/models/items.dart';
import 'package:cambridge_seller/splashScreen/my_splash_screen.dart';
import '../global/global.dart';

class ItemsDetailsScreen extends StatefulWidget {
  final Items? model;

  ItemsDetailsScreen({this.model});

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  // List of all possible sizes
  final List<String> allSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  // Get available sizes as a list
  List<String> get availableSizes {
    return (widget.model?.sizesAvailable ?? '').split(',')
        .map((size) => size.trim())
        .where((size) => size.isNotEmpty)
        .toList();
  }

  // Size availability display widget
  Widget buildSizesDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Sizes:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allSizes.map((size) {
            bool isAvailable = availableSizes.contains(size);

            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
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
                ),
                if (!isAvailable)
                  const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 24,
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  deleteItem() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () {
              Navigator.pop(ctx);
              FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(sharedPreferences!.getString("uid"))
                  .collection("brands")
                  .doc(widget.model?.brandID)
                  .collection("items")
                  .doc(widget.model?.itemID)
                  .delete()
                  .then((value) {
                FirebaseFirestore.instance
                    .collection("items")
                    .doc(widget.model?.itemID)
                    .delete();

                Fluttertoast.showToast(msg: "Item Deleted Successfully.");
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  editItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => EditItemScreen(model: widget.model),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
        title: Text(
          widget.model?.itemTitle ?? 'Item Details',
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "editItem",
            onPressed: () {
              editItem();
            },
            label: const Text("Edit Item"),
            icon: const Icon(Icons.edit, color: Colors.white),
            backgroundColor: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: "deleteItem",
            onPressed: () {
              deleteItem();
            },
            label: const Text("Delete Item"),
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Image
              Center(
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.model?.thumbnailUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: screenWidth * 0.2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sizes Display
              buildSizesDisplay(),
              const SizedBox(height: 20),

              // Item Title
              Text(
                "${widget.model?.itemTitle ?? 'No Title Available'}:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              // Long Description
              Text(
                widget.model?.longDescription ?? 'No Description Available',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              const SizedBox(height: 10),
              // Price
              Text(
                "₹${widget.model?.price ?? 'N/A'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.07,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // Divider
              Divider(
                height: 2,
                thickness: 2,
                color: Colors.black,
                indent: screenWidth * 0.02,
                endIndent: screenWidth * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}