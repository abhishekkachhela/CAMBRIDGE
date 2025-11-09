import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cambridge_seller/models/items.dart';
import '../global/global.dart';

class EditItemScreen extends StatefulWidget {
  final Items? model;
  final String? brandID;

  EditItemScreen({this.model, this.brandID});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController itemTitleController = TextEditingController();
  TextEditingController itemInfoController = TextEditingController();
  TextEditingController longDescriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController sizesController = TextEditingController();

  String selectedQuantity = "1";
  List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<bool> selectedSizes = [false, false, false, false, false];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.model != null;

    if (isEditing) {
      itemTitleController.text = widget.model?.itemTitle ?? '';
      itemInfoController.text = widget.model?.itemInfo ?? '';
      longDescriptionController.text = widget.model?.longDescription ?? '';
      priceController.text = widget.model?.price ?? '';
      quantityController.text = widget.model?.quantityInStock ?? '1';
      selectedQuantity = widget.model?.quantityInStock ?? '1';

      String savedSizes = widget.model?.sizesAvailable ?? '';
      sizesController.text = savedSizes;
      if (savedSizes.isNotEmpty) {
        List<String> sizesList = savedSizes.split(',');
        for (int i = 0; i < sizes.length; i++) {
          selectedSizes[i] = sizesList.contains(sizes[i]);
        }
      }
    }
  }

  Future<void> saveItemDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String uid = sharedPreferences!.getString("uid") ?? '';
        if (uid.isEmpty) {
          Fluttertoast.showToast(msg: "User ID not found");
          return;
        }

        // Convert all values to non-null strings
        Map<String, dynamic> itemData = {
          "itemTitle": itemTitleController.text.trim(),
          "itemInfo": itemInfoController.text.trim(),
          "longDescription": longDescriptionController.text.trim(),
          "price": priceController.text.trim(),
          "quantityInStock": quantityController.text,
          "sizesAvailable": sizesController.text,
          "publishedDate": Timestamp.now(),
          "status": "available",
        };

        if (isEditing && widget.model?.itemID != null && widget.model?.brandID != null) {
          // Update existing item
          await FirebaseFirestore.instance
              .collection("sellers")
              .doc(uid)
              .collection("brands")
              .doc(widget.model!.brandID)
              .collection("items")
              .doc(widget.model!.itemID)
              .update(itemData);

          await FirebaseFirestore.instance
              .collection("items")
              .doc(widget.model!.itemID)
              .update(itemData);

          Fluttertoast.showToast(msg: "Item updated successfully.");
        } else if (widget.brandID != null) {
          // Add new item
          final brandRef = FirebaseFirestore.instance
              .collection("sellers")
              .doc(uid)
              .collection("brands")
              .doc(widget.brandID);

          final newItemRef = brandRef.collection("items").doc();

          // Add additional fields for new items
          itemData.addAll({
            "sellerUID": uid,
            "brandID": widget.brandID,
            "itemID": newItemRef.id,
          });

          await newItemRef.set(itemData);
          await FirebaseFirestore.instance
              .collection("items")
              .doc(newItemRef.id)
              .set(itemData);

          Fluttertoast.showToast(msg: "Item added successfully.");
        } else {
          Fluttertoast.showToast(msg: "Brand ID is missing");
          return;
        }

        Navigator.pop(context);
      } catch (error) {
        Fluttertoast.showToast(msg: "Error saving item: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(isEditing ? "Edit Item" : "Add Item"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Item Title Field
                TextFormField(
                  controller: itemTitleController,
                  decoration: const InputDecoration(
                    labelText: "Item Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the item title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Item Info Field
                TextFormField(
                  controller: itemInfoController,
                  decoration: const InputDecoration(
                    labelText: "Short Description",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a short description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Long Description Field
                TextFormField(
                  controller: longDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Long Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a detailed description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Price Field
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "Price (₹)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the price";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Quantity Dropdown
                DropdownButtonFormField<String>(
                  value: selectedQuantity,
                  decoration: const InputDecoration(
                    labelText: "Quantity in Stock",
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(100, (index) => (index + 1).toString())
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedQuantity = newValue;
                        quantityController.text = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Sizes Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Available Sizes",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: List.generate(sizes.length, (index) {
                        return FilterChip(
                          label: Text(sizes[index]),
                          selected: selectedSizes[index],
                          onSelected: (bool selected) {
                            setState(() {
                              selectedSizes[index] = selected;
                              sizesController.text = sizes
                                  .asMap()
                                  .entries
                                  .where((entry) => selectedSizes[entry.key])
                                  .map((entry) => entry.value)
                                  .join(',');
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Save Button
                ElevatedButton(
                  onPressed: saveItemDetails,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 15.0),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text(
                    isEditing ? "Update Item" : "Add Item",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}