import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
Widget commoniconElevatedButtonbuild(
  BuildContext context,
  String text,
  VoidCallback? onPressed,
  IconData icons,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.all(15),
    child: ElevatedButton.icon(
      icon: Icon(icons, color: isDarkMode ? mainBlackColor : mainWhiteColor),

      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? mainWhiteColor : mainBlackColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(250)),
        elevation: 2,
      ),
      label: Text(
        text,
        style: TextStyle(color: isDarkMode ? mainBlackColor : mainWhiteColor),
      ),
    ),
  );
}
