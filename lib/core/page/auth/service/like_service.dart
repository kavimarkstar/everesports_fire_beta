import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/core/page/home/model/like.dart';

class LikeServiceUser {
  static Db? _db;
  static DbCollection? _likesCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      try {
        _db = await Db.create(configDatabase);
        await _db!.open();
        _likesCollection = _db!.collection('likes');
      } catch (e) {
        print('Error connecting to database: $e');
        rethrow;
      }
    }
  }

  // Like a post
  static Future<bool> likePost(
    String userId,
    String postId,
    String postOwnerId,
  ) async {
    try {
      await _initializeDatabase();

      // Check if user already liked this post
      final existingLike = await _likesCollection!.findOne(
        where.eq('userId', userId).eq('postId', postId),
      );

      if (existingLike != null) {
        // User already liked this post, so unlike it
        await _likesCollection!.deleteOne(
          where.eq('userId', userId).eq('postId', postId),
        );
        return false; // Post is now unliked
      } else {
        // User hasn't liked this post, so like it
        final db = _db!;
        final postsCollection = db.collection('posts');
        dynamic post;
        // Try to find the post by ObjectId or string
        try {
          post = await postsCollection.findOne({'_id': ObjectId.parse(postId)});
        } catch (_) {
          post = await postsCollection.findOne({'_id': postId});
        }
        final ownerUserId = post?['userId']?.toString();

        final likeData = {
          '_id': ObjectId(),
          'userId': userId,
          'postId': postId,
          'postOwnerId': postOwnerId,
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _likesCollection!.insert(likeData);
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
      await _initializeDatabase();

      final like = await _likesCollection!.findOne(
        where.eq('userId', userId).eq('postId', postId),
      );

      return like != null;
    } catch (e) {
      print('Error checking if user liked post: $e');
      return false;
    }
  }

  // Get like count for a post
  static Future<int> getLikeCount(String postId) async {
    try {
      await _initializeDatabase();

      final count = await _likesCollection!.count(where.eq('postId', postId));

      return count;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }

  // Get all likes for a post
  static Future<List<Like>> getLikesForPost(String postId) async {
    try {
      await _initializeDatabase();

      final cursor = await _likesCollection!.find(
        where.eq('postId', postId).sortBy('createdAt', descending: true),
      );

      final List<Like> likes = [];
      await for (final document in cursor) {
        likes.add(Like.fromMap(document));
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
      await _initializeDatabase();

      final cursor = await _likesCollection!.find(where.eq('userId', userId));

      final List<String> postIds = [];
      await for (final document in cursor) {
        postIds.add(document['postId']);
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
      await _initializeDatabase();
      final db = _db!;
      final postsCollection = db.collection('posts');
      // Get all posts created by this user
      final userPosts = await postsCollection.find({'userId': userId}).toList();
      if (userPosts.isEmpty) {
        print('No posts found for user: $userId');
        return 0;
      }
      // Collect all postId strings and ObjectIds from _id
      final postIdStrings = <String>[];
      final postIdObjects = <ObjectId>[];
      for (final p in userPosts) {
        if (p['_id'] != null) {
          postIdStrings.add(p['_id'].toString());
          if (p['_id'] is ObjectId) postIdObjects.add(p['_id'] as ObjectId);
        }
      }
      if (postIdStrings.isEmpty && postIdObjects.isEmpty) {
        print('No postId values found for user: $userId');
        return 0;
      }
      // Count likes for all these postId values (string and ObjectId)
      final count = await _likesCollection!.count({
        'or': [
          {
            'postId': {'in': postIdStrings},
          },
          {
            'postId': {'in': postIdObjects},
          },
        ],
      });
      print(
        'User $userId has $count likes on their posts (matching postId as string or ObjectId from _id)',
      );
      return count;
    } catch (e) {
      print('Error getting user posts like count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given
  static Future<int> getLikesGivenCount(String userId) async {
    try {
      await _initializeDatabase();
      final count = await _likesCollection!.count({'userId': userId});
      return count;
    } catch (e) {
      print('Error getting likes given count: $e');
      return 0;
    }
  }

  // Get the number of likes the user has given to other users' posts
  static Future<int> getLikesGivenToOthersCount(String userId) async {
    try {
      await _initializeDatabase();
      final db = _db!;
      final postsCollection = db.collection('posts');
      // Get all likes given by this user
      final likes = await _likesCollection!.find({'userId': userId}).toList();
      if (likes.isEmpty) return 0;
      int count = 0;
      for (final like in likes) {
        final postId = like['postId'];
        if (postId == null) continue;
        // Find the post and check if it was created by someone else
        final post = await postsCollection.findOne({
          '_id': ObjectId.parse(postId),
        });
        if (post != null && post['userId'] != userId) {
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
      await _initializeDatabase();
      // Query likes where userId == likerUserId and ownerUserId == postOwnerId
      final count = await _likesCollection!.count({
        'userId': likerUserId,
        'ownerUserId': postOwnerId,
      });
      return count;
    } catch (e) {
      print('Error getting likes given to user: $e');
      return 0;
    }
  }

  // Get the number of likes received by the user's posts
  static Future<int> getLikesReceivedCount(String postOwnerId) async {
    try {
      await _initializeDatabase();
      final count = await _likesCollection!.count({'postOwnerId': postOwnerId});
      return count;
    } catch (e) {
      print('Error getting likes received count: $e');
      return 0;
    }
  }
}

Future<void> addOwnerUserIdToLikes() async {
  final db = await Db.create(configDatabase);
  await db.open();
  final postsCollection = db.collection('posts');
  final likesCollection = db.collection('likes');

  // 1. Build a map of postId (as string) -> ownerUserId
  final posts = await postsCollection.find().toList();
  final Map<String, String> postIdToOwner = {};
  for (final post in posts) {
    final postId = post['_id'] is ObjectId
        ? (post['_id'] as ObjectId).toHexString()
        : post['_id'].toString();
    final ownerUserId = post['userId']?.toString();
    if (postId != null && ownerUserId != null) {
      postIdToOwner[postId] = ownerUserId;
    }
  }

  // 2. Update each like with the ownerUserId
  final likes = await likesCollection.find().toList();
  for (final like in likes) {
    String? postId;
    if (like['postId'] is ObjectId) {
      postId = (like['postId'] as ObjectId).toHexString();
    } else if (like['postId'] is String) {
      // If stored as ObjectId("...") string, extract the hex
      final match = RegExp(
        r'ObjectId\("([a-f0-9]+)"\)',
      ).firstMatch(like['postId']);
      if (match != null) {
        postId = match.group(1);
      } else {
        postId = like['postId'];
      }
    }
    final ownerUserId = postIdToOwner[postId];
    if (ownerUserId != null) {
      await likesCollection.updateOne(
        where.id(like['_id']),
        modify.set('ownerUserId', ownerUserId),
      );
    }
  }

  await db.close();
  print('All likes updated with ownerUserId!');
}
