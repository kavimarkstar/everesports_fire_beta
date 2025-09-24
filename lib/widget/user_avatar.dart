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

  bool _isProbablyBase64(String value) {
    // Heuristic: long string without spaces, only base64 chars, divisible by 4
    final s = value.trim();
    if (s.length < 40) return false;
    if (s.contains(' ') || s.contains('/')) {
      // allow leading "/9j" etc. but many paths have '/'
      // If it looks like a path (contains '/') and also contains '.', treat as path
      if (s.contains('.') && s.contains('/')) return false;
    }
    final base64Reg = RegExp(r'^[A-Za-z0-9+\/=]+$');
    return base64Reg.hasMatch(s) && (s.length % 4 == 0);
  }

  ImageProvider? _getImageProvider() {
    if (profileImage == null || profileImage!.isEmpty) return null;

    // Check if it is a Base64 string
    if (profileImage!.startsWith('data:image') ||
        _isProbablyBase64(profileImage!)) {
      try {
        // Remove prefix if exists
        String base64Str = profileImage!.contains(',')
            ? profileImage!.split(',').last
            : profileImage!;
        // Fix missing padding for base64
        final mod = base64Str.length % 4;
        if (mod != 0) {
          base64Str = base64Str + '=' * (4 - mod);
        }
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
      backgroundColor: Colors.transparent,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(Icons.person, size: radius, color: Colors.grey[600])
          : null,
    );
  }
}
