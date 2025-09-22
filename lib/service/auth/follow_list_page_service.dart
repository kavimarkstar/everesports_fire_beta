import 'package:everesports/database/config/config.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DatabaseService {
  static late Db _db;
  static bool _isInitialized = false;

  static final String _connectionString = configDatabase;

  // Collection names
  static const String followingCollection = 'following';
  static const String usersCollection = 'users';

  // Initialize the database connection
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _db = Db(_connectionString);
      await _db.open();
      _isInitialized = true;
    }
  }

  // Get the database instance
  static Db get db {
    if (!_isInitialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _db;
  }

  // Close the database connection
  static Future<void> close() async {
    if (_isInitialized) {
      await _db.close();
      _isInitialized = false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserFollowing(
    String userId,
  ) async {
    final following = await db
        .collection('following')
        .find(where.eq('userId', userId))
        .toList();

    return await _enrichWithUserDetails(following, 'followingId');
  }

  static Future<List<Map<String, dynamic>>> getUserFollowers(
    String userId,
  ) async {
    final followers = await db
        .collection('following')
        .find(where.eq('followingId', userId))
        .toList();

    return await _enrichWithUserDetails(followers, 'userId');
  }

  static Future<List<Map<String, dynamic>>> _enrichWithUserDetails(
    List<Map<String, dynamic>> relationships,
    String idField,
  ) async {
    return await Future.wait(
      relationships.map((rel) async {
        final user = await db
            .collection('users')
            .findOne(where.eq('_id', ObjectId.fromHexString(rel[idField])));
        if (user == null) return rel;
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

  // Add more database operations as needed...
}
