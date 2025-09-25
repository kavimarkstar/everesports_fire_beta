import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference get _followingCollection =>
      _firestore.collection('following');
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');

  static Future<void> followUser(
    String currentUserId,
    String targetUserId,
  ) async {
    await _followingCollection.add({
      'userId': currentUserId,
      'followingId': targetUserId,
      'followedAt': FieldValue.serverTimestamp(),
      'postview': false,
    });
  }

  static Future<void> unfollowUser(
    String currentUserId,
    String targetUserId,
  ) async {
    final query = await _followingCollection
        .where('userId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  static Future<bool> isFollowing(
    String currentUserId,
    String targetUserId,
  ) async {
    final query = await _followingCollection
        .where('userId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  static Future<int> followersCount(String userId) async {
    final query = await _followingCollection
        .where('followingId', isEqualTo: userId)
        .get();
    return query.docs.length;
  }

  static Future<int> followingCount(String userId) async {
    final query = await _followingCollection
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.length;
  }

  static Future<List<Map<String, dynamic>>> getFollowingList(
    String userId,
  ) async {
    final followingQuery = await _followingCollection
        .where('userId', isEqualTo: userId)
        .get();
    if (followingQuery.docs.isEmpty) return [];
    final followingIds = followingQuery.docs
        .map((doc) => doc['followingId'] as String)
        .toList();

    if (followingIds.isEmpty) return [];

    // Firestore doesn't support 'in' queries with more than 10 elements
    List<Map<String, dynamic>> users = [];
    for (var chunk in _chunkList(followingIds, 10)) {
      final usersQuery = await _usersCollection
          .where('userId', whereIn: chunk)
          .get();
      users.addAll(
        usersQuery.docs.map(
          (userDoc) => {
            'userId': userDoc['userId'],
            'username': userDoc['username'],
            'name': userDoc['name'],
          },
        ),
      );
    }
    return users;
  }

  static Future<List<Map<String, dynamic>>> getFollowersList(
    String userId,
  ) async {
    final followersQuery = await _followingCollection
        .where('followingId', isEqualTo: userId)
        .get();
    if (followersQuery.docs.isEmpty) return [];
    final followerIds = followersQuery.docs
        .map((doc) => doc['userId'] as String)
        .toList();

    if (followerIds.isEmpty) return [];

    List<Map<String, dynamic>> users = [];
    for (var chunk in _chunkList(followerIds, 10)) {
      final usersQuery = await _usersCollection
          .where('userId', whereIn: chunk)
          .get();
      users.addAll(
        usersQuery.docs.map(
          (userDoc) => {
            'userId': userDoc['userId'],
            'username': userDoc['username'],
            'name': userDoc['name'],
          },
        ),
      );
    }
    return users;
  }

  static Future<List<String>> getFollowingUserIds(String userId) async {
    final query = await _followingCollection
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => doc['followingId'] as String).toList();
  }

  static Future<List<String>> getFollowerUserIds(String userId) async {
    final query = await _followingCollection
        .where('followingId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => doc['userId'] as String).toList();
  }

  // Helper to chunk a list into pieces of size n (for Firestore 'in' queries)
  static List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }
}
