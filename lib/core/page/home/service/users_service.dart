import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/auth/model/user_profile.dart';
import 'package:everesports/service/auth/follow_service.dart';

class UsersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection = _firestore.collection(
    'users',
  );

  // Get all users with pagination for sidebar
  static Future<List<UserProfile>> getUsersForSidebar({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit + skip)
          .get();

      final docs = querySnapshot.docs.skip(skip).take(limit);

      return docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting users for sidebar: $e');
      return [];
    }
  }

  // Get users with following status for current user using FollowService
  static Future<List<Map<String, dynamic>>> getUsersWithFollowingStatus({
    required String currentUserId,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit + skip)
          .get();

      final docs = querySnapshot.docs.skip(skip).take(limit);

      // Get following relationships for current user using FollowService
      final followingIds = await FollowService.getFollowingUserIds(
        currentUserId,
      );

      // Combine user data with following status
      final usersWithStatus = docs.map((doc) {
        final user = doc.data() as Map<String, dynamic>;
        final userId = user['userId'] as String?;

        // Check if current user is following this user using userId field
        final isFollowing = userId != null && followingIds.contains(userId);

        // Check if this is the current user (compare by userId field)
        final isCurrentUser = userId == currentUserId;

        return {
          'user': UserProfile.fromMap(user),
          'isFollowing': isFollowing,
          'followedAt': null, // We can get this later if needed
          'isCurrentUser': isCurrentUser,
        };
      }).toList();

      return usersWithStatus;
    } catch (e) {
      print('Error getting users with following status: $e');
      return [];
    }
  }

  // Get following count for a user using FollowService
  static Future<int> getFollowingCount(String userId) async {
    try {
      return await FollowService.followingCount(userId);
    } catch (e) {
      print('Error getting following count: $e');
      return 0;
    }
  }

  // Get followers count for a user using FollowService
  static Future<int> getFollowersCount(String userId) async {
    try {
      return await FollowService.followersCount(userId);
    } catch (e) {
      print('Error getting followers count: $e');
      return 0;
    }
  }

  // Get users by search query
  static Future<List<UserProfile>> searchUsers(String query) async {
    try {
      // Firestore does not support OR queries with regex directly.
      // We'll do two separate queries and merge results.
      final usernameQuery = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final nameQuery = await _usersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final usersMap = <String, UserProfile>{};

      for (var doc in usernameQuery.docs) {
        usersMap[doc.id] = UserProfile.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }
      for (var doc in nameQuery.docs) {
        usersMap[doc.id] = UserProfile.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }

      return usersMap.values.toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // No need to close Firestore connection in Flutter
  static Future<void> close() async {
    // No-op for Firestore
  }
}
