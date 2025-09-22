import 'package:flutter/material.dart';

void shareSpark(
  String title,
  String description,
  String username,
  BuildContext context,
) {
  // In a real app, this would use the share plugin
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Sharing $title by $username"),
      duration: const Duration(seconds: 2),
    ),
  );
}
