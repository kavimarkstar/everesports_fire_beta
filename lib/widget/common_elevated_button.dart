import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

@override
Widget commonElevatedButtonbuild(
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
        backgroundColor: isDarkMode ? mainWhiteColor : mainBlackColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(250)),
        elevation: 2,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? mainBlackColor : mainWhiteColor,
        ),
      ),
    ),
  );
}

@override
Widget commonElevatedButtonWidgetbuild(
  BuildContext context,
  Widget content,
  VoidCallback? onPressed,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.all(15),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? mainWhiteColor : mainBlackColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(250)),
        elevation: 2,
      ),
      child: content,
    ),
  );
}

Widget commonElevatedButtonFollowPostsButtonbuild(
  BuildContext context,
  String text,
  VoidCallback? onPressed,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.all(5),
    child: SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? mainWhiteColor : mainBlackColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(250),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? mainBlackColor : mainWhiteColor,
          ),
        ),
      ),
    ),
  );
}
