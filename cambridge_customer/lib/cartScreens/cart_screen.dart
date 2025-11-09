import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cambridge_customer/addressScreens/address_screen.dart';
import 'package:cambridge_customer/assistantMethods/cart_item_counter.dart';
import 'package:cambridge_customer/assistantMethods/total_amount.dart';
import 'package:cambridge_customer/cartScreens/cart_item_design_widget.dart';
import 'package:cambridge_customer/global/global.dart';
import 'package:cambridge_customer/models/items.dart';
import 'package:cambridge_customer/splashScreen/my_splash_screen.dart';
import 'package:cambridge_customer/widgets/appbar_cart_badge.dart';
import 'package:cambridge_customer/sellersScreens/home_screen.dart';

class CartScreen extends StatefulWidget {
  final String? sellerUID;

  const CartScreen({Key? key, this.sellerUID}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<int>? itemQuantityList;
  List<String>? itemIdList;
  double totalAmount = 0.0;
  Map<String, int> stockAvailability = {};

  @override
  void initState() {
    super.initState();
    itemQuantityList = cartMethods.separateItemQuantitiesFromUserCartList();
    itemIdList = cartMethods.separateItemIDsFromUserCartList();
    loadStockAvailability();
    updateTotalAmount();
  }

  Future<void> loadStockAvailability() async {
    if (itemIdList != null && itemIdList!.isNotEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("items")
          .where("itemID", whereIn: itemIdList)
          .get();

      for (var doc in querySnapshot.docs) {
        Items model = Items.fromJson(doc.data() as Map<String, dynamic>);
        if (model.itemID != null && model.quantityInStock != null) {
          stockAvailability[model.itemID!] = int.parse(model.quantityInStock!);
        }
      }

      // Adjust quantities if they exceed available stock
      for (int i = 0; i < itemIdList!.length; i++) {
        String itemId = itemIdList![i];
        int availableStock = stockAvailability[itemId] ?? 0;
        if (itemQuantityList![i] > availableStock) {
          setState(() {
            itemQuantityList![i] = availableStock;
          });
          storeCartData();
        }
      }

      setState(() {});
    }
  }

  bool canIncrementQuantity(String itemId, int currentQuantity) {
    int available = stockAvailability[itemId] ?? 0;
    return currentQuantity < available;
  }

  void updateTotalAmount() async {
    if (itemIdList != null && itemIdList!.isNotEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("items")
          .where("itemID", whereIn: itemIdList)
          .get();

      double calculatedTotal = 0.0;
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Items model = Items.fromJson(querySnapshot.docs[i].data() as Map<String, dynamic>);
        calculatedTotal += double.parse(model.price!) * itemQuantityList![i];
      }

      Provider.of<TotalAmount>(context, listen: false).showTotalAmountOfCartItems(calculatedTotal);
      setState(() {
        totalAmount = calculatedTotal;
      });
    }
  }

  void storeCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart', itemIdList!);
    await prefs.setStringList('itemQuantities', itemQuantityList!.map((e) => e.toString()).toList());
  }

  void updateItemQuantity(int index, int newQuantity) {
    String itemId = itemIdList![index];
    int availableStock = stockAvailability[itemId] ?? 0;

    if (newQuantity <= availableStock) {
      setState(() {
        itemQuantityList![index] = newQuantity;
      });
      updateTotalAmount();
      storeCartData();
    } else {
      // Show error or warning message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only $availableStock items available in stock'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          "Cart",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () {
                cartMethods.clearCart(context);
                storeCartData();
                Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));
              },
              heroTag: "btn1",
              icon: const Icon(Icons.clear_all),
              label: const Text("Clear Cart", style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () {
                storeCartData();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => AddressScreen(
                      sellerUID: widget.sellerUID.toString(),
                      totalAmount: totalAmount.toDouble(),
                    ),
                  ),
                );
              },
              heroTag: "btn2",
              icon: const Icon(Icons.navigate_next),
              label: const Text("Check Out", style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () {
                storeCartData();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              heroTag: "btn3",
              icon: const Icon(Icons.shopping_bag),
              label: const Text("Continue Shopping", style: TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black54,
              child: Consumer2<TotalAmount, CartItemCounter>(
                builder: (context, amountProvider, cartProvider, c) {
                  return Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: cartProvider.count == 0
                          ? Container()
                          : Text(
                        "Total Price: ₹${amountProvider.tAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          StreamBuilder(
            stream: itemIdList!.isNotEmpty
                ? FirebaseFirestore.instance
                .collection("items")
                .where("itemID", whereIn: itemIdList!)
                .orderBy("publishedDate", descending: true)
                .snapshots()
                : Stream.empty(),
            builder: (context, AsyncSnapshot dataSnapshot) {
              if (dataSnapshot.hasData) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      Items model = Items.fromJson(
                          dataSnapshot.data.docs[index].data() as Map<String, dynamic>);

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CartItemDesignWidget(
                          model: model,
                          quantityNumber: itemQuantityList![index],
                          onQuantityChanged: (newQuantity) {
                            updateItemQuantity(index, newQuantity);
                          },
                        ),
                      );
                    },
                    childCount: dataSnapshot.data.docs.length,
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "No items exist in cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}