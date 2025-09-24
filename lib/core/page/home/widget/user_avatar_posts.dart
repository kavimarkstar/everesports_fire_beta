import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget buildUserAvatar(
  BuildContext context,
  Uint8List profileImageUrl,
  VoidCallback? onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 25,
      backgroundImage: MemoryImage(profileImageUrl),
    ),
  );
}
