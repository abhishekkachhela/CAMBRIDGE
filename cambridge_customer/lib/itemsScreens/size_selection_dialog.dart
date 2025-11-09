import 'package:flutter/material.dart';

class SizeSelectionDialog extends StatefulWidget {
  final List<String> availableSizes;
  final Function(String) onSizeSelected;

  const SizeSelectionDialog({
    Key? key,
    required this.availableSizes,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  State<SizeSelectionDialog> createState() => _SizeSelectionDialogState();
}

class _SizeSelectionDialogState extends State<SizeSelectionDialog> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.availableSizes.map((size) {
          return ListTile(
            title: Text(size),
            selected: selectedSize == size,
            onTap: () {
              setState(() {
                selectedSize = size;
              });
              widget.onSizeSelected(size);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}