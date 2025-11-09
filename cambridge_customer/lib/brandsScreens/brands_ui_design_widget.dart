import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../itemsScreens/items_screen.dart';
import '../models/brands.dart';
import '../splashScreen/my_splash_screen.dart';

class BrandsUiDesignWidget extends StatefulWidget {
  Brands? model;

  BrandsUiDesignWidget({this.model});

  @override
  State<BrandsUiDesignWidget> createState() => _BrandsUiDesignWidgetState();
}

class _BrandsUiDesignWidgetState extends State<BrandsUiDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ItemsScreen(
              model: widget.model,
            ),
          ),
        );
      },
      child: Center( // Centering the entire card widget
        child: Card(
          color: Colors.black,
          elevation: 10,
          shadowColor: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width for the card
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make the column take minimum space
                children: [
                  // Use Flexible to allow the layout to adjust dynamically
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        widget.model!.thumbnailUrl.toString(),
                        fit: BoxFit.cover,
                        width: double.infinity, // makes image width responsive
                        height: MediaQuery.of(context).size.height * 0.3, // flexible height
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title with some spacing for readability
                  Text(
                    widget.model!.brandTitle.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
