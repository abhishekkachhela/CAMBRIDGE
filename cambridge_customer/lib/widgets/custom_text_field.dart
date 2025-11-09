import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final IconData iconData;
  final String hintText;
  final bool isObsecre;
  final bool enabled;
  final Widget? suffixIcon; // Optional suffix icon parameter

  const CustomTextField({
    required this.textEditingController,
    required this.iconData,
    required this.hintText,
    required this.isObsecre,
    required this.enabled,
    this.suffixIcon, // Initialize it here
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: textEditingController,
        obscureText: isObsecre,
        enabled: enabled,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          prefixIcon: Icon(
            iconData,
            color: Colors.grey,
          ),
          suffixIcon: suffixIcon, // Add suffixIcon to the TextFormField
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
