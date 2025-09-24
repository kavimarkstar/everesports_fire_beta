import 'package:cloud_firestore/cloud_firestore.dart';

class FollowListPageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String followingCollection = 'following';
  static const String usersCollection = 'users';

  /// Get the list of users that the given user is following
  static Future<List<Map<String, dynamic>>> getUserFollowing(
    String userId,
  ) async {
    final followingSnapshot = await _firestore
        .collection(followingCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final following = followingSnapshot.docs.map((doc) => doc.data()).toList();

    return await _enrichWithUserDetails(following, 'followingId');
  }

  /// Get the list of users that are following the given user
  static Future<List<Map<String, dynamic>>> getUserFollowers(
    String userId,
  ) async {
    final followersSnapshot = await _firestore
        .collection(followingCollection)
        .where('followingId', isEqualTo: userId)
        .get();

    final followers = followersSnapshot.docs.map((doc) => doc.data()).toList();

    return await _enrichWithUserDetails(followers, 'userId');
  }

  /// Helper to enrich following/follower relationships with user details
  static Future<List<Map<String, dynamic>>> _enrichWithUserDetails(
    List<Map<String, dynamic>> relationships,
    String idField,
  ) async {
    return await Future.wait(
      relationships.map((rel) async {
        final userId = rel[idField];
        if (userId == null) return rel;

        final userSnapshot = await _firestore
            .collection(usersCollection)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (userSnapshot.docs.isEmpty) return rel;

        final user = userSnapshot.docs.first.data();

        return {
          'userId': user['userId'],
          'username': user['username'],
          'name': user['name'],
          'profileImageUrl': user['profileImageUrl'],
          'followedAt': rel['followedAt'],
        };
      }),
    );
  }

  // Add more Firestore-based operations as needed...
}
