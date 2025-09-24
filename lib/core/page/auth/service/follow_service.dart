import 'package:cloud_firestore/cloud_firestore.dart';

class FollowServiceUser {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _followingCollection = 'following';
  static final String _usersCollection = 'users';

  /// Follow a user
  static Future<void> followUser(
    String currentUserId,
    String targetUserId,
  ) async {
    final now = DateTime.now();
    // Prevent duplicate follows
    final existing = await _firestore
        .collection(_followingCollection)
        .where('userId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      await _firestore.collection(_followingCollection).add({
        'userId': currentUserId,
        'followingId': targetUserId,
        'followedAt': now.toIso8601String(),
      });
    }
  }

  /// Unfollow a user
  static Future<void> unfollowUser(
    String currentUserId,
    String targetUserId,
  ) async {
    final query = await _firestore
        .collection(_followingCollection)
        .where('userId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  /// Check if currentUserId is following targetUserId
  static Future<bool> isFollowing(
    String currentUserId,
    String targetUserId,
  ) async {
    final query = await _firestore
        .collection(_followingCollection)
        .where('userId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Get the number of followers for a user
  static Future<int> followersCount(String userId) async {
    final query = await _firestore
        .collection(_followingCollection)
        .where('followingId', isEqualTo: userId)
        .get();
    return query.docs.length;
  }

  /// Get the number of users a user is following
  static Future<int> followingCount(String userId) async {
    final query = await _firestore
        .collection(_followingCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.length;
  }

  /// Get the list of users that the given user is following
  static Future<List<Map<String, dynamic>>> getFollowingList(
    String userId,
  ) async {
    final followingQuery = await _firestore
        .collection(_followingCollection)
        .where('userId', isEqualTo: userId)
        .get();
    if (followingQuery.docs.isEmpty) return [];
    final followingIds = followingQuery.docs
        .map((doc) => doc['followingId'] as String)
        .toList();

    if (followingIds.isEmpty) return [];

    // Firestore doesn't support 'in' with more than 10 elements, so batch if needed
    List<Map<String, dynamic>> users = [];
    for (var i = 0; i < followingIds.length; i += 10) {
      final batchIds = followingIds.sublist(
        i,
        i + 10 > followingIds.length ? followingIds.length : i + 10,
      );
      final usersQuery = await _firestore
          .collection(_usersCollection)
          .where('userId', whereIn: batchIds)
          .get();
      users.addAll(
        usersQuery.docs.map((doc) {
          final data = doc.data();
          return {
            'userId': data['userId'],
            'username': data['username'],
            'name': data['name'],
          };
        }),
      );
    }
    return users;
  }

  /// Get the list of users who follow the given user
  static Future<List<Map<String, dynamic>>> getFollowersList(
    String userId,
  ) async {
    final followersQuery = await _firestore
        .collection(_followingCollection)
        .where('followingId', isEqualTo: userId)
        .get();
    if (followersQuery.docs.isEmpty) return [];
    final followerIds = followersQuery.docs
        .map((doc) => doc['userId'] as String)
        .toList();

    if (followerIds.isEmpty) return [];

    // Firestore doesn't support 'in' with more than 10 elements, so batch if needed
    List<Map<String, dynamic>> users = [];
    for (var i = 0; i < followerIds.length; i += 10) {
      final batchIds = followerIds.sublist(
        i,
        i + 10 > followerIds.length ? followerIds.length : i + 10,
      );
      final usersQuery = await _firestore
          .collection(_usersCollection)
          .where('userId', whereIn: batchIds)
          .get();
      users.addAll(
        usersQuery.docs.map((doc) {
          final data = doc.data();
          return {
            'userId': data['userId'],
            'username': data['username'],
            'name': data['name'],
          };
        }),
      );
    }
    return users;
  }

  /// Get the list of userIds that the given user is following
  static Future<List<String>> getFollowingUserIds(String userId) async {
    final query = await _firestore
        .collection(_followingCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => doc['followingId'] as String).toList();
  }

  /// Get the list of userIds who follow the given user
  static Future<List<String>> getFollowerUserIds(String userId) async {
    final query = await _firestore
        .collection(_followingCollection)
        .where('followingId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => doc['userId'] as String).toList();
  }
}
