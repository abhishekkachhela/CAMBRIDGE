import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cambridge_customer/assistantMethods/cart_item_counter.dart';
import 'package:cambridge_customer/global/global.dart';

class CartMethods {
  // Add item to cart
  addItemToCart(String? itemId, int itemCounter, BuildContext context) {
    List<String>? tempList = sharedPreferences!.getStringList("userCart");
    tempList!.add(itemId.toString() + ":" + itemCounter.toString()); // 2367121:5

    // Save to Firestore database
    FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .update({
      "userCart": tempList,
    }).then((value) {
      Fluttertoast.showToast(msg: "Item added successfully.");

      // Save to local storage
      sharedPreferences!.setStringList("userCart", tempList);

      // Update item badge number
      Provider.of<CartItemCounter>(context, listen: false)
          .showCartListItemsNumber();
    });
  }

  // Clear the cart
  clearCart(BuildContext context) {
    // Clear in local storage
    sharedPreferences!.setStringList("userCart", ["initialValue"]);

    List<String>? emptyCartList = sharedPreferences!.getStringList("userCart");

    FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .update({
      "userCart": emptyCartList,
    }).then((value) {
      // Update item badge number
      Provider.of<CartItemCounter>(context, listen: false)
          .showCartListItemsNumber();
    });
  }

  // Separate item IDs from user cart list
  separateItemIDsFromUserCartList() {
    List<String>? userCartList = sharedPreferences!.getStringList("userCart");

    List<String> itemsIDsList = [];
    for (int i = 1; i < userCartList!.length; i++) {
      String item = userCartList[i].toString();
      var lastCharacterPositionOfItemBeforeColon = item.lastIndexOf(":");

      String getItemID = item.substring(0, lastCharacterPositionOfItemBeforeColon);
      itemsIDsList.add(getItemID);
    }

    return itemsIDsList;
  }

  // Separate item quantities from user cart list
  separateItemQuantitiesFromUserCartList() {
    List<String>? userCartList = sharedPreferences!.getStringList("userCart");

    List<int> itemsQuantitiesList = [];
    for (int i = 1; i < userCartList!.length; i++) {
      String item = userCartList[i].toString();
      var colonAndAfterCharactersList = item.split(":").toList();

      var quantityNumber = int.parse(colonAndAfterCharactersList[1].toString());
      itemsQuantitiesList.add(quantityNumber);
    }
    return itemsQuantitiesList;
  }

  // Separate order item IDs
  separateOrderItemIDs(productIDs) {
    List<String>? userCartList = List<String>.from(productIDs);

    List<String> itemsIDsList = [];
    for (int i = 1; i < userCartList.length; i++) {
      String item = userCartList[i].toString();
      var lastCharacterPositionOfItemBeforeColon = item.lastIndexOf(":");

      String getItemID = item.substring(0, lastCharacterPositionOfItemBeforeColon);
      itemsIDsList.add(getItemID);
    }

    return itemsIDsList;
  }

  // Separate order item quantities
  separateOrderItemsQuantities(productIDs) {
    List<String>? userCartList = List<String>.from(productIDs);

    List<String> itemsQuantitiesList = [];
    for (int i = 1; i < userCartList.length; i++) {
      String item = userCartList[i].toString();
      var colonAndAfterCharactersList = item.split(":").toList();

      var quantityNumber = int.parse(colonAndAfterCharactersList[1].toString());
      itemsQuantitiesList.add(quantityNumber.toString());
    }
    return itemsQuantitiesList;
  }

  // Method to get the cart item count
  int getCartItemCount() {
    List<String>? cartList = sharedPreferences!.getStringList("userCart");
    return cartList != null ? cartList.length - 1 : 0;  // Subtract 1 for the initialValue
  }
}