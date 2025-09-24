import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/home/model/like.dart';

class LikeServiceUser {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _likesCollection = 'likes';
  static final String _postsCollection = 'posts';

  // Like or unlike a post (toggle)
  static Future<bool> likePost(
    String userId,
    String postId,
    String postOwnerId,
  ) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef
          .where('userId', isEqualTo: userId)
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // User already liked this post, so unlike it
        await likesRef.doc(query.docs.first.id).delete();
        return false; // Post is now unliked
      } else {
        // User hasn't liked this post, so like it
        final likeData = {
          'userId': userId,
          'postId': postId,
          'postOwnerId': postOwnerId,
          'createdAt': DateTime.now().toIso8601String(),
        };
        await likesRef.add(likeData);
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
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef
          .where('userId', isEqualTo: userId)
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user liked post: $e');
      return false;
    }
  }

  // Get like count for a post
  static Future<int> getLikeCount(String postId) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef.where('postId', isEqualTo: postId).get();
      return query.size;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }

  // Get all likes for a post
  static Future<List<Like>> getLikesForPost(String postId) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Like> likes = [];
      for (final doc in query.docs) {
        likes.add(Like.fromMap(doc.data()));
      }
      return likes;
    } catch (e) {
      print('Error getting likes for post: $e');
      return [];
    }
  }

  // Get all posts liked by a user
  static Future<List<String>> getPostsLikedByUser(String userId) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef.where('userId', isEqualTo: userId).get();

      final List<String> postIds = [];
      for (final doc in query.docs) {
        postIds.add(doc.data()['postId'] as String);
      }
      return postIds;
    } catch (e) {
      print('Error getting posts liked by user: $e');
      return [];
    }
  }

  // Get the total like count for all posts created by a user
  static Future<int> getUserPostsLikeCount(String userId) async {
    try {
      // Get all posts created by this user
      final postsQuery = await _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      if (postsQuery.docs.isEmpty) {
        print('No posts found for user: $userId');
        return 0;
      }
      final postIds = postsQuery.docs.map((doc) => doc.id).toList();
      if (postIds.isEmpty) {
        print('No postId values found for user: $userId');
        return 0;
      }
      // Count likes for all these postId values
      final likesRef = _firestore.collection(_likesCollection);
      final likesQuery = await likesRef
          .where(
            'postId',
            whereIn: postIds.length > 10 ? postIds.sublist(0, 10) : postIds,
          )
          .get();
      // Firestore whereIn supports max 10 elements, so if more, do multiple queries
      int count = likesQuery.size;
      if (postIds.length > 10) {
        for (int i = 10; i < postIds.length; i += 10) {
          final subIds = postIds.sublist(
            i,
            i + 10 > postIds.length ? postIds.length : i + 10,
          );
          final subQuery = await likesRef
              .where('postId', whereIn: subIds)
              .get();
          count += subQuery.size;
        }
      }
      print('User $userId has $count likes on their posts');
      return count;
    } catch (e) {
      print('Error getting user posts like count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given
  static Future<int> getLikesGivenCount(String userId) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef.where('userId', isEqualTo: userId).get();
      return query.size;
    } catch (e) {
      print('Error getting likes given count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given to other users' posts
  static Future<int> getLikesGivenToOthersCount(String userId) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef.where('userId', isEqualTo: userId).get();
      if (query.docs.isEmpty) return 0;
      int count = 0;
      for (final doc in query.docs) {
        final data = doc.data();
        if (data['postOwnerId'] != null && data['postOwnerId'] != userId) {
          count++;
        }
      }
      print('User $userId has given $count likes to other users\' posts');
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
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef
          .where('userId', isEqualTo: likerUserId)
          .where('postOwnerId', isEqualTo: postOwnerId)
          .get();
      return query.size;
    } catch (e) {
      print('Error getting likes given to user: $e');
      return 0;
    }
  }

  // Get the number of likes received by the user's posts
  static Future<int> getLikesReceivedCount(String postOwnerId) async {
    try {
      final likesRef = _firestore.collection(_likesCollection);
      final query = await likesRef
          .where('postOwnerId', isEqualTo: postOwnerId)
          .get();
      return query.size;
    } catch (e) {
      print('Error getting likes received count: $e');
      return 0;
    }
  }
}

// This function is not needed in Firestore, as you should store postOwnerId at like creation time.
// If you need to backfill, you can run a migration script outside of the app.
Future<void> addOwnerUserIdToLikes() async {
  print(
    'addOwnerUserIdToLikes is not required for Firestore. '
    'Ensure postOwnerId is set when creating a like.',
  );
}
