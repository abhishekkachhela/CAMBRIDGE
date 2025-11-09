import 'package:flutter/material.dart';
import '../models/items.dart';
import 'items_details_screen.dart';

class ItemsUiDesignWidget extends StatefulWidget {
  final Items? model;

  ItemsUiDesignWidget({this.model});

  @override
  State<ItemsUiDesignWidget> createState() => _ItemsUiDesignWidgetState();
}

class _ItemsUiDesignWidgetState extends State<ItemsUiDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return Center( // Ensures the entire Card is centered
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => ItemsDetailsScreen(model: widget.model),
            ),
          );
        },
        child: Center(
          child: Card(
            color: Colors.black,
            elevation: 10,
            shadowColor: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrinks column to wrap its content
                mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    child: AspectRatio(
                      aspectRatio: 4 / 3, // Maintains image's aspect ratio
                      child: Image.network(
                        widget.model!.thumbnailUrl.toString(),
                        fit: BoxFit.cover, // Makes the image responsive
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.model!.itemTitle.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center, // Centers the text horizontally
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.model!.itemInfo.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center, // Centers the text horizontally
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
