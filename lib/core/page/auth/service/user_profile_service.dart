import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import '../model/user_profile.dart';

class UserProfileService {
  static Db? _db;
  static DbCollection? _usersCollection;
  static DbCollection? _followersCollection;
  static DbCollection? _followingCollection;
  static DbCollection? _likesCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      try {
        _db = await Db.create(configDatabase);
        await _db!.open();
        _usersCollection = _db!.collection('users');
        _followersCollection = _db!.collection('followers');
        _followingCollection = _db!.collection('following');
        _likesCollection = _db!.collection('likes');
      } catch (e) {
        print('Error connecting to database: $e');
        rethrow;
      }
    }
  }

  // Get user profile by ObjectId
  static Future<UserProfile?> getUserProfileById(String objectIdHex) async {
    try {
      await _initializeDatabase();

      final user = await _usersCollection!.findOne(
        where.id(ObjectId.fromHexString(objectIdHex)),
      );

      if (user != null) {
        return UserProfile.fromMap(user);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by ID: $e');
      return null;
    }
  }

  // Get user data by ObjectId (alternative method)
  static Future<Map<String, dynamic>?> getUserDataByObjectId(
    String objectIdHex,
  ) async {
    try {
      await _initializeDatabase();

      final user = await _usersCollection!.findOne(
        where.id(ObjectId.fromHexString(objectIdHex)),
      );

      return user;
    } catch (e) {
      print('Error fetching user data by ObjectId: $e');
      return null;
    }
  }

  // Get user profile by userId (string)
  static Future<UserProfile?> getUserProfileByUserId(String userId) async {
    try {
      await _initializeDatabase();

      final user = await _usersCollection!.findOne(where.eq('userId', userId));

      if (user != null) {
        return UserProfile.fromMap(user);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by userId: $e');
      return null;
    }
  }

  // Get user profile by username
  static Future<UserProfile?> getUserProfileByUsername(String username) async {
    try {
      await _initializeDatabase();

      final user = await _usersCollection!.findOne(
        where.eq('username', username),
      );

      if (user != null) {
        return UserProfile.fromMap(user);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by username: $e');
      return null;
    }
  }

  // Get followers count
  static Future<int> getFollowersCount(String userId) async {
    try {
      await _initializeDatabase();

      return await _followersCollection!.count(where.eq('followingId', userId));
    } catch (e) {
      print('Error getting followers count: $e');
      return 0;
    }
  }

  // Get following count
  static Future<int> getFollowingCount(String userId) async {
    try {
      await _initializeDatabase();

      return await _followingCollection!.count(where.eq('userId', userId));
    } catch (e) {
      print('Error getting following count: $e');
      return 0;
    }
  }

  // Get likes count (total likes received by user)
  static Future<int> getLikesCount(String userId) async {
    try {
      await _initializeDatabase();

      // Get all posts by user
      final posts = await _db!
          .collection('posts')
          .find(where.eq('userId', userId))
          .toList();

      int totalLikes = 0;
      for (final post in posts) {
        final likesCount = await _likesCollection!.count(
          where.eq('postId', post['_id'].toString()),
        );
        totalLikes += likesCount;
      }

      return totalLikes;
    } catch (e) {
      print('Error getting likes count: $e');
      return 0;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _initializeDatabase();

      // Use modify with set operations for each field
      final modifier = modify;
      updates.forEach((key, value) {
        modifier.set(key, value);
      });

      final result = await _usersCollection!.updateOne(
        where.eq('userId', userId),
        modifier,
      );

      return result.isSuccess;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Search users by username or name
  static Future<List<UserProfile>> searchUsers(String query) async {
    try {
      await _initializeDatabase();

      // Use simple equality search instead of regex for now
      final users = await _usersCollection!
          .find(where.eq('username', query))
          .toList();

      return users.map((user) => UserProfile.fromMap(user)).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get all users (with pagination)
  static Future<List<UserProfile>> getAllUsers({
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
      print('Error getting all users: $e');
      return [];
    }
  }

  // Close database connection
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _usersCollection = null;
      _followersCollection = null;
      _followingCollection = null;
      _likesCollection = null;
    }
  }
}
