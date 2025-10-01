import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fetch base64 data for a photo by its files_id from the `photos` collection.
Future<String?> fetchPhotoData(String filesId) async {
  try {
    final q = await FirebaseFirestore.instance
        .collection('photos')
        .where('files_id', isEqualTo: filesId)
        .limit(1)
        .get();
    if (q.docs.isNotEmpty) {
      final d = q.docs.first.data();
      return d['data'] as String?;
    }
  } catch (e) {
    if (kDebugMode) print('fetchPhotoData error: $e');
  }
  return null;
}

/// A reusable grid widget for displaying bookmarked posts.
class GridViewProfilePost extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final RefreshCallback? onRefresh;
  final void Function(Map<String, dynamic> post)? onTap;
  final void Function(Map<String, dynamic> post)? onLongPress;
  final Widget Function(Map<String, dynamic> post)? ownerActionBuilder;

  const GridViewProfilePost({
    Key? key,
    required this.posts,
    this.onRefresh,
    this.onTap,
    this.onLongPress,
    this.ownerActionBuilder,
  }) : super(key: key);

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }

  /// Build a plain image widget (no aspect ratio) — caller wraps it into the
  /// tile's AspectRatio to ensure square tiles.
  Widget _buildImageWidget(Map<String, dynamic> post) {
    final images = post['images'] as List<dynamic>? ?? [];
    final photoBinary = post['photoBinary'] as Map<String, dynamic>?;

    // Determine first image entry
    String? imageStr;
    if (images.isNotEmpty) {
      final first = images.first;
      if (first is String) imageStr = first;
      if (first is Map<String, dynamic>) imageStr = first['url']?.toString();
    }

    // Data URL
    if (imageStr != null && imageStr.startsWith('data:')) {
      try {
        final comma = imageStr.indexOf(',');
        final base64Part = comma >= 0
            ? imageStr.substring(comma + 1)
            : imageStr;
        final bytes = base64Decode(base64Part);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        if (kDebugMode) print('Error decoding data URL: $e');
      }
    }

    // Raw base64
    if (imageStr != null &&
        !imageStr.startsWith('http') &&
        !imageStr.startsWith('https')) {
      try {
        final bytes = base64Decode(imageStr);
        if (bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }
      } catch (_) {}
    }

    // Network URL
    if (imageStr != null &&
        (imageStr.startsWith('http') || imageStr.startsWith('https'))) {
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    // photoBinary fallback
    if (photoBinary != null && photoBinary['data'] is String) {
      try {
        final bytes = base64Decode(photoBinary['data'] as String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        if (kDebugMode) print('Error decoding photoBinary: $e');
      }
    }

    return _buildPlaceholderImage();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: posts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile(context) ? 3 : 4,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          childAspectRatio: 0.75,
        ),

        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                // Only call the provided callback. Do not navigate automatically.
                onTap?.call(post);
              },
              onLongPress: () => onLongPress?.call(post),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageWidget(post),
                    // If the post is marked private, show a small lock badge
                    if ((post['isPrivate'] == true) ||
                        (post['isprivert'] == true))
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    // Optional owner action widget (e.g., small privacy toggle)
                    if (ownerActionBuilder != null)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: ownerActionBuilder!(post),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
