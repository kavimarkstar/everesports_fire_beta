import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
Widget commonTextfieldbuild(
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
    padding: EdgeInsets.all(16.0),
    child: TextField(
      
      controller: controller,
      
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        labelText: labelText,
        labelStyle: TextStyle(color: mainColor),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: mainColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: mainColor, width: 0.5),
        ),
      ),
      style: TextStyle(
        fontSize: 17,
        color: isDarkMode ? mainWhiteColor : mainBlackColor,
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    ),
  );
}

Widget commonDropdownbuild<T>(
  BuildContext context, {
  required String hintText,
  required String labelText,
  required T? value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T?> onChanged,
  String? Function(T?)? validator,
}) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                itemLabel(e),
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkMode ? mainWhiteColor : mainBlackColor,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
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
          borderSide: BorderSide(color: mainColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: mainColor, width: 0.5),
        ),
      ),
    ),
  );
}
