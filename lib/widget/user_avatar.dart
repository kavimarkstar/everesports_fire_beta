import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:everesports/database/config/config.dart';

class UserAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final double radius;

  const UserAvatar({
    Key? key,
    this.profileImageUrl,
    this.radius = 18,
    ImageProvider<Object>? memoryImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      String fullImageUrl = profileImageUrl!.startsWith('http')
          ? profileImageUrl!
          : '$fileServerBaseUrl/${profileImageUrl!.startsWith('/') ? profileImageUrl!.substring(1) : profileImageUrl!}';
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(fullImageUrl),
        onBackgroundImageError: (_, __) {},
        child: Icon(Icons.person, size: radius, color: Colors.grey[600]),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: radius, color: Colors.grey[600]),
    );
  }
}

class FireBaseUserAvatar extends StatelessWidget {
  final String? profileImage;
  final double radius;

  const FireBaseUserAvatar({Key? key, this.profileImage, this.radius = 18})
    : super(key: key);

  ImageProvider? _getImageProvider() {
    if (profileImage == null || profileImage!.isEmpty) return null;

    // Check if it is a Base64 string
    if (profileImage!.startsWith('data:image') ||
        !profileImage!.startsWith('http')) {
      try {
        // Remove prefix if exists
        final base64Str = profileImage!.contains(',')
            ? profileImage!.split(',').last
            : profileImage!;
        Uint8List bytes = base64Decode(base64Str);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    // Otherwise treat as network URL
    String url = profileImage!.startsWith('http')
        ? profileImage!
        : '$fileServerBaseUrl/${profileImage!.startsWith('/') ? profileImage!.substring(1) : profileImage!}';
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(Icons.person, size: radius, color: Colors.grey[600])
          : null,
    );
  }
}
