import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bookmark';

  static Future<void> addBookmark(
    String userId,
    String postId,
    String albumId,
  ) async {
    await _firestore.collection(_collectionName).add({
      'userId': userId,
      'postId': postId,
      'albumId': albumId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> removeBookmark(
    String userId,
    String postId,
    String albumId,
  ) async {
    final query = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .where('albumId', isEqualTo: albumId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  static Future<bool> isBookmarked(
    String userId,
    String postId,
    String albumId,
  ) async {
    final query = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .where('albumId', isEqualTo: albumId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  static Future<int> getBookmarkCount(String postId) async {
    final query = await _firestore
        .collection(_collectionName)
        .where('postId', isEqualTo: postId)
        .get();
    return query.docs.length;
  }

  static Future<List<String>> getBookmarkedPostIdsByUser(
    String userId,
    String albumId,
  ) async {
    final query = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('albumId', isEqualTo: albumId)
        .get();

    return query.docs.map((doc) => doc.data()['postId'] as String).toList();
  }
}
