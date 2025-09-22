import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
Widget commonTextButtonLoginbuild(
  BuildContext context,
  String text,
  VoidCallback? onPressed,
) {
  return TextButton(
    onPressed: onPressed,
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      overlayColor: MaterialStateProperty.all(
        Colors.transparent,
      ), // no ripple color
      foregroundColor: MaterialStateProperty.all(mainColor),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
    ),
    child: Text(text),
  );
}
