import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/core/page/auth/model/user_profile.dart';
import 'package:everesports/service/auth/follow_service.dart';

class UsersService {
  static Db? _db;
  static DbCollection? _usersCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      try {
        _db = await Db.create(configDatabase);
        await _db!.open();
        _usersCollection = _db!.collection('users');
      } catch (e) {
        print('Error connecting to database: $e');
        rethrow;
      }
    }
  }

  // Get all users with pagination for sidebar
  static Future<List<UserProfile>> getUsersForSidebar({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      await _initializeDatabase();

      final users = await _usersCollection!
          .find(
            where.sortBy('createdAt', descending: true).skip(skip).limit(limit),
          )
          .toList();

      return users.map((user) => UserProfile.fromMap(user)).toList();
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
      await _initializeDatabase();

      // Get all users
      final users = await _usersCollection!
          .find(
            where.sortBy('createdAt', descending: true).skip(skip).limit(limit),
          )
          .toList();

      // Get following relationships for current user using FollowService
      final followingIds = await FollowService.getFollowingUserIds(
        currentUserId,
      );

      // Combine user data with following status
      final usersWithStatus = users.map((user) {
        final userObjectId = user['_id'] as ObjectId;
        final userId = userObjectId.toHexString();

        // Check if current user is following this user using userId field
        final isFollowing = followingIds.contains(user['userId']);

        // Check if this is the current user (compare by userId field, not ObjectId)
        final isCurrentUser = user['userId'] == currentUserId;

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
      await _initializeDatabase();

      final users = await _usersCollection!.find({
        '\$or': [
          {
            'username': {'\$regex': query, '\$options': 'i'},
          },
          {
            'name': {'\$regex': query, '\$options': 'i'},
          },
        ],
      }).toList();

      return users.map((user) => UserProfile.fromMap(user)).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Close database connection
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _usersCollection = null;
    }
  }
}
