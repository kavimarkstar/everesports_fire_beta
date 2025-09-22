import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
Widget commonTextButtonbuild(
  BuildContext context,
  String content,
  VoidCallback onPressed,
) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: Colors.white, // text/icon color
      backgroundColor: isDarkMode
          ? secondBlackColor
          : secondWhiteColor, // button background color
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 0.50,
          color: isDarkMode ? mainWhiteColor : mainBlackColor,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Text(
      content,
      style: TextStyle(color: isDarkMode ? mainWhiteColor : mainBlackColor),
    ),
  );
}
