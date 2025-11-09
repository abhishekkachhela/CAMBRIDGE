import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cambridge_customer/assistantMethods/cart_item_counter.dart';
import 'package:cambridge_customer/cartScreens/cart_screen.dart';

class AppBarWithCartBadge extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? preferredSizeWidget;
  final String? sellerUID;

  AppBarWithCartBadge({this.preferredSizeWidget, this.sellerUID});

  @override
  State<AppBarWithCartBadge> createState() => _AppBarWithCartBadgeState();

  @override
  Size get preferredSize =>
      preferredSizeWidget == null ? Size(56, AppBar().preferredSize.height) : Size(56, 80 + AppBar().preferredSize.height);
}

class _AppBarWithCartBadgeState extends State<AppBarWithCartBadge> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.white54],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )),
      ),
      automaticallyImplyLeading: true,
      title: const Text(
        "Cambridge",
        style: TextStyle(fontSize: 20, letterSpacing: 3),
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                int itemsInCart = Provider.of<CartItemCounter>(context, listen: false).count;

                if (itemsInCart == 0) {
                  Fluttertoast.showToast(msg: "Cart is empty. \nPlease first add some items to cart.");
                } else {
                  // Ensure sellerUID is not null
                  if (widget.sellerUID != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => CartScreen(sellerUID: widget.sellerUID),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(msg: "Seller information not available.");
                  }
                }
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.black,
              ),
            ),
            Positioned(
              child: Stack(
                children: [
                  const Icon(
                    Icons.brightness_1,
                    size: 20,
                    color: Colors.black,
                  ),
                  Positioned(
                    top: 2,
                    right: 6,
                    child: Center(
                      child: Consumer<CartItemCounter>(builder: (context, counter, c) {
                        return Text(
                          counter.count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
