import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final IconData? iconData;
  final String? hintText;
  bool? isObsecre;
  final bool? enabled;
  final Widget? suffixIcon; // <-- Add suffixIcon parameter

  CustomTextField({
    this.textEditingController,
    this.iconData,
    this.hintText,
    this.isObsecre = true, // Default to obscure text
    this.enabled = true,
    this.suffixIcon, // <-- Accept suffixIcon here
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: widget.enabled,
        controller: widget.textEditingController,
        obscureText: widget.isObsecre!, // Obscure or show the text
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            widget.iconData,
            color: Colors.redAccent,
          ),
          suffixIcon: widget.suffixIcon, // <-- Display suffix icon if provided
          focusColor: Theme.of(context).primaryColor,
          hintText: widget.hintText,
        ),
      ),
    );
  }
}
