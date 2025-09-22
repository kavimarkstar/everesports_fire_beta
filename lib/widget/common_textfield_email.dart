import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

Widget commonTextfieldEmailbuild(
  BuildContext context,
  String hintText,
  String labelText,
  TextEditingController controller, {
  bool obscureText = false,
  bool readOnly = false,
  String? Function(String?)? validator,
}) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: labelText,
        labelStyle: TextStyle(color: mainColor),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: mainColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: mainColor, width: 1),
        ),
      ),
      style: TextStyle(
        fontSize: 17,
        color: isDarkMode ? mainWhiteColor : mainBlackColor,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
    ),
  );
}
