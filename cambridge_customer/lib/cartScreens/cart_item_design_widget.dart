import 'package:flutter/material.dart';
import 'package:cambridge_customer/models/items.dart';

class CartItemDesignWidget extends StatelessWidget {
  final Items? model;
  final int? quantityNumber;
  final Function(int) onQuantityChanged;

  const CartItemDesignWidget({
    Key? key,
    this.model,
    this.quantityNumber,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;
    double cardHeight = 120.0;

    return Card(
      color: Colors.black,
      shadowColor: Colors.white54,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: cardHeight,
          width: cardWidth,
          child: Row(
            children: [
              Image.network(
                model!.thumbnailUrl.toString(),
                width: 100,
                height: 120,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model!.itemTitle.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          "Price: ",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          "₹ ",
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          model!.price.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          "Quantity: ",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantityNumber! > 1) {
                              onQuantityChanged(quantityNumber! - 1);
                            }
                          },
                        ),
                        Text(
                          quantityNumber.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            onQuantityChanged(quantityNumber! + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}