import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
Widget commonLineElevatedButtonbuild(
  BuildContext context,
  String text,
  VoidCallback? onPressed,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.all(15),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(250)),
        side: BorderSide(
          color: isDarkMode ? mainWhiteColor : mainBlackColor,
          width: 2,
        ),
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? mainWhiteColor : mainBlackColor,
        ),
      ),
    ),
  );
}
