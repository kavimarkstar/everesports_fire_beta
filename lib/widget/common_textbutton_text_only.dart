import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
// ignore: non_constant_identifier_names
Widget CommonTextButtonTextOnlybuild(
  BuildContext context,
  String content,
  VoidCallback onPressed,
) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: Colors.white, // text/icon color
      backgroundColor: Colors.transparent, // button background color
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    child: Text(content, style: TextStyle(color: mainColor)),
  );
}
