import 'package:flutter/cupertino.dart';
import 'package:cambridge_customer/global/global.dart';
import 'package:cambridge_customer/assistantMethods/cart_methods.dart';

class CartItemCounter extends ChangeNotifier {
  int cartListItemCounter = 0;

  CartItemCounter() {
    _initializeCartItemCount();
  }

  int get count => cartListItemCounter;

  // Initialize cart item count from sharedPreferences
  void _initializeCartItemCount() {
    if (sharedPreferences!.getStringList("userCart") != null) {
      cartListItemCounter = sharedPreferences!.getStringList("userCart")!.length;
    }
  }

  // Show cart list items number
  Future<void> showCartListItemsNumber() async {
    // Get cart item count using CartMethods
    cartListItemCounter = CartMethods().getCartItemCount();

    await Future.delayed(const Duration(milliseconds: 100), () {
      notifyListeners();  // Notify listeners to update UI
    });
  }
}
