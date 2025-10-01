import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

Widget postActionButton(
  BuildContext context,
  String icon,
  String label,
  VoidCallback? onPressed, {
  bool isLiked = false,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Row(
    children: [
      IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.transparent : Colors.transparent,
          foregroundColor: Colors.transparent,
          focusColor: isDarkMode ? Colors.transparent : Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          splashFactory: InkRipple.splashFactory,
        ),
        icon: Image.asset(
          icon,
          height: 30,
          color: isLiked
              ? mainColor
              : (isDarkMode ? mainWhiteColor : mainBlackColor),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          color: (isDarkMode ? mainWhiteColor : mainBlackColor),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 2),
    ],
  );
}

Widget postActionBookmarkButton(
  BuildContext context,
  String icon,
  String label,
  VoidCallback? onPressed, {
  bool isLiked = false,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Row(
    children: [
      IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.transparent : Colors.transparent,
          foregroundColor: Colors.transparent,
          focusColor: isDarkMode ? Colors.transparent : Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          splashFactory: InkRipple.splashFactory,
        ),
        icon: Image.asset(
          icon,
          height: 30,
          // When bookmarked (isLiked) tint with mainColor to make it visually distinct.
          // Otherwise use default color depending on theme.
          color: isLiked
              ? mainColor
              : (isDarkMode ? mainWhiteColor : mainBlackColor),
        ),
      ),
      const SizedBox(width: 5),
      Text(label),
      const SizedBox(width: 2),
    ],
  );
}

// Universal count formatter
String formatCount(int count) {
  if (count >= 1000000000) {
    return '${(count / 1000000000).toStringAsFixed(1)} B';
  } else if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)} M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)} K';
  } else {
    return count.toString();
  }
}
