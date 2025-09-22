import 'package:everesports/service/auth/auth_service.dart' show AuthService;
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class FollowServiceUser {
  static mongo.Db get _db => AuthService.db;
  static mongo.DbCollection get _followingCollection =>
      _db.collection('following');

  static Future<void> followUser(
    String currentUserId,
    String targetUserId,
  ) async {
    final now = DateTime.now();
    await _followingCollection.insertOne({
      'userId': currentUserId,
      'followingId': targetUserId,
      'followedAt': now.toIso8601String(),
    });
  }

  static Future<void> unfollowUser(
    String currentUserId,
    String targetUserId,
  ) async {
    await _followingCollection.deleteOne({
      'userId': currentUserId,
      'followingId': targetUserId,
    });
  }

  static Future<bool> isFollowing(
    String currentUserId,
    String targetUserId,
  ) async {
    final doc = await _followingCollection.findOne({
      'userId': currentUserId,
      'followingId': targetUserId,
    });
    return doc != null;
  }

  static Future<int> followersCount(String userId) async {
    return await _followingCollection.count({'followingId': userId});
  }

  static Future<int> followingCount(String userId) async {
    return await _followingCollection.count({'userId': userId});
  }

  static Future<List<Map<String, dynamic>>> getFollowingList(
    String userId,
  ) async {
    final followingDocs = await _followingCollection.find({
      'userId': userId,
    }).toList();
    if (followingDocs.isEmpty) return [];
    final db = _db;
    final usersCollection = db.collection('users');
    final followingIds = followingDocs
        .map((doc) => doc['followingId'])
        .toList();
    final users = await usersCollection.find({
      'userId': {'in': followingIds},
    }).toList();
    return users
        .map(
          (user) => {
            'userId': user['userId'],
            'username': user['username'],
            'name': user['name'],
          },
        )
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getFollowersList(
    String userId,
  ) async {
    final followerDocs = await _followingCollection.find({
      'followingId': userId,
    }).toList();
    if (followerDocs.isEmpty) return [];
    final db = _db;
    final usersCollection = db.collection('users');
    final followerIds = followerDocs.map((doc) => doc['userId']).toList();
    final users = await usersCollection.find({
      'userId': {'in': followerIds},
    }).toList();
    return users
        .map(
          (user) => {
            'userId': user['userId'],
            'username': user['username'],
            'name': user['name'],
          },
        )
        .toList();
  }

  static Future<List<String>> getFollowingUserIds(String userId) async {
    final docs = await _followingCollection.find({'userId': userId}).toList();
    return docs.map((doc) => doc['followingId'] as String).toList();
  }

  static Future<List<String>> getFollowerUserIds(String userId) async {
    final docs = await _followingCollection.find({
      'followingId': userId,
    }).toList();
    return docs.map((doc) => doc['userId'] as String).toList();
  }
}
