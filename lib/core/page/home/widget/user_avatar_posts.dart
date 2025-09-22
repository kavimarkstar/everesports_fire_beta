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
      radius: 20,
      backgroundImage: MemoryImage(profileImageUrl),
    ),
  );
}
