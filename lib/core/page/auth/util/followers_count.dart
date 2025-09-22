import 'package:flutter/material.dart';

@override
Widget followCountbuild(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Text("45", style: TextStyle(color: Colors.black)),
            Text("Following", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Text("45", style: TextStyle(color: Colors.black)),
            Text("Following", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Text("45", style: TextStyle(color: Colors.black)),
            Text("Following", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    ],
  );
}
