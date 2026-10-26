import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final Radius? topRight;
  final Radius? bottomRight;
  final Radius? bottomLeft;
  final Radius? topLeft;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final EdgeInsets? contentPadding;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged; // <-- Added this

  const CustomInput({
    super.key,
    required this.hintText,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
    this.topLeft,
    required this.controller,
    required this.keyboardType,
    this.contentPadding,
    this.maxLines = 1,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.onChanged, // <-- Added this
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onChanged: onChanged, // <-- Connected here
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: topLeft ?? Radius.circular(15.0),
            topRight: topRight ?? Radius.circular(15.0),
            bottomLeft: bottomLeft ?? Radius.circular(15.0),
            bottomRight: bottomRight ?? Radius.circular(15.0),
          ),
          borderSide: const BorderSide(color: Colors.purple, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: topLeft ?? Radius.circular(15.0),
            topRight: topRight ?? Radius.circular(15.0),
            bottomLeft: bottomLeft ?? Radius.circular(15.0),
            bottomRight: bottomRight ?? Radius.circular(15.0),
          ),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: topLeft ?? Radius.circular(15.0),
            topRight: topRight ?? Radius.circular(15.0),
            bottomLeft: bottomLeft ?? Radius.circular(15.0),
            bottomRight: bottomRight ?? Radius.circular(15.0),
          ),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: topLeft ?? Radius.circular(15.0),
            topRight: topRight ?? Radius.circular(15.0),
            bottomLeft: bottomLeft ?? Radius.circular(15.0),
            bottomRight: bottomRight ?? Radius.circular(15.0),
          ),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}