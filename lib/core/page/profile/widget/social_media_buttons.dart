import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/addGame/add_game.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

@override
Widget socialMediaButtonbuild(BuildContext context) {
  return Row(
    children: [
      Spacer(),
      elevetorButtonbuild(context, "Add Games", AddGamePage()),
      SizedBox(width: 3),
      elevetorButtonbuild(context, "Manage Games", AddGamePage()),
      Spacer(),
    ],
  );
}

@override
Widget elevetorButtonbuild(BuildContext context, String title, Widget page) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
    child: ElevatedButton(
      onPressed: () {
        commonNavigationbuild(context, page);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isDark ? Colors.grey[800] : secondWhiteGrayColor,
        ),
        overlayColor: MaterialStateProperty.all(
          isDark ? Colors.grey[1000] : Colors.grey[1000],
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(color: isDark ? mainWhiteColor : mainBlackColor),
      ),
    ),
  );
}
