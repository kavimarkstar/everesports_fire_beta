import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/home/model/like.dart';

class LikeService {
  static final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // Like or unlike a post (toggle)
  static Future<bool> likePost(
    String userId,
    String postId,
    String postOwnerId,
  ) async {
    try {
      final String docId = '${userId}_$postId';
      final docRef = _fs.collection('likes').doc(docId);
      final existing = await docRef.get();
      if (existing.exists) {
        await docRef.delete();
        return false; // Post is now unliked
      } else {
        await docRef.set({
          'userId': userId,
          'postId': postId,
          'postOwnerId': postOwnerId,
          'likeViewed': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true; // Post is now liked
      }
    } catch (e) {
      print('Error liking/unliking post: $e');
      return false;
    }
  }

  // Check if user has liked a post
  static Future<bool> hasUserLikedPost(String userId, String postId) async {
    try {
      final String docId = '${userId}_$postId';
      final docRef = _fs.collection('likes').doc(docId);
      final like = await docRef.get();
      return like.exists;
    } catch (e) {
      print('Error checking if user liked post: $e');
      return false;
    }
  }

  // Get like count for a post
  static Future<int> getLikeCount(String postId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }

  // Get all likes for a post
  static Future<List<Like>> getLikesForPost(String postId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .get();
      return q.docs.map((doc) => Like.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting likes for post: $e');
      return [];
    }
  }

  // Get all posts liked by a user
  static Future<List<String>> getPostsLikedByUser(String userId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .get();
      return q.docs.map((doc) => doc.data()['postId'] as String).toList();
    } catch (e) {
      print('Error getting posts liked by user: $e');
      return [];
    }
  }

  // Get the total like count for all posts created by a user
  static Future<int> getUserPostsLikeCount(String userId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('postOwnerId', isEqualTo: userId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Error getting user posts like count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given
  static Future<int> getLikesGivenCount(String userId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Error getting likes given count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given to other users' posts
  static Future<int> getLikesGivenToOthersCount(String userId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .get();
      int count = 0;
      for (final doc in q.docs) {
        final data = doc.data();
        if (data['postOwnerId'] != null && data['postOwnerId'] != userId) {
          count++;
        }
      }
      return count;
    } catch (e) {
      print('Error getting likes given to others count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given to a specific user's posts
  static Future<int> getLikesGivenToUser(
    String likerUserId,
    String postOwnerId,
  ) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('userId', isEqualTo: likerUserId)
          .where('postOwnerId', isEqualTo: postOwnerId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Error getting likes given to user: $e');
      return 0;
    }
  }

  // Get the number of likes received by the user's posts
  static Future<int> getLikesReceivedCount(String postOwnerId) async {
    try {
      final q = await _fs
          .collection('likes')
          .where('postOwnerId', isEqualTo: postOwnerId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Error getting likes received count: $e');
      return 0;
    }
  }
}
