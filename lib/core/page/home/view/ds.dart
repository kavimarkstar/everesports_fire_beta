import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all posts that are images (jpg) from Firestore
  Future<List<ImagePost>> fetchImagePosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .where('filetype', isEqualTo: 'jpg')
        .orderBy('uploadDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ImagePost(
        filesId: doc['files_id'],
        description: doc['description'] ?? '',
      );
    }).toList();
  }

  /// Reconstruct image from chunks and return temporary file path
  Future<String> getImageFilePath(String filesId) async {
    final snapshot = await _firestore
        .collection('photos')
        .where('files_id', isEqualTo: filesId)
        .orderBy('n')
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No image chunks found for $filesId");
    }

    final List<int> allBytes = [];
    for (var doc in snapshot.docs) {
      final data = doc['data'] as String;
      allBytes.addAll(base64Decode(data));
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$filesId.jpg';
    final file = File(filePath);
    await file.writeAsBytes(allBytes);
    return file.path;
  }
}

/// Simple data model for an image post
class ImagePost {
  final String filesId;
  final String description;

  ImagePost({required this.filesId, required this.description});
}
