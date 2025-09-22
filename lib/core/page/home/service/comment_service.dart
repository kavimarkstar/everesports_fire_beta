import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/core/page/home/model/comment.dart';

class CommentService {
  static Db? _db;
  static DbCollection? _commentsCollection;
  static DbCollection? _likesCollection;
  static DbCollection? _notificationsCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      try {
        _db = await Db.create(configDatabase);
        await _db!.open();
        _commentsCollection = _db!.collection('comments');
      } catch (e) {
        print('Error connecting to database: $e');
        rethrow;
      }
    }
  }

  static Future<void> _initializeLikeDatabase() async {
    if (_db == null) {
      await _initializeDatabase();
    }
    _likesCollection ??= _db!.collection('comments_like');
    _notificationsCollection ??= _db!.collection('notifications');
  }

  // Add a comment to a post
  static Future<Comment?> addComment(
    String userId,
    String postId,
    String content, [
    String? parentId,
  ]) async {
    try {
      await _initializeDatabase();
      _notificationsCollection ??= _db!.collection('notifications');

      final commentData = {
        '_id': ObjectId(),
        'userId': userId,
        'postId': postId,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        if (parentId != null) 'parentId': parentId,
      };

      final commentObjectId = commentData['_id'];
      await _commentsCollection!.insert(commentData);

      // Mention notification logic
      final mentionRegExp = RegExp(r'@(\w+)');
      final matches = mentionRegExp.allMatches(content);
      if (_db != null) {
        DbCollection? usersCollection = _db!.collection('users');
        for (final match in matches) {
          final username = match.group(1);
          if (username != null &&
              usersCollection != null &&
              _notificationsCollection != null) {
            final mentionedUser = await usersCollection.findOne({
              'username': username,
            });
            print('Mentioned user for @$username: $mentionedUser');
            String? mentionedUserId;
            if (mentionedUser != null && mentionedUser['_id'] != null) {
              if (mentionedUser['_id'] is ObjectId) {
                mentionedUserId = mentionedUser['_id'].toHexString();
              } else {
                mentionedUserId = mentionedUser['_id'].toString();
              }
            }
            String? commentId;
            if (commentObjectId != null && commentObjectId is ObjectId) {
              commentId = commentObjectId.toHexString();
            } else if (commentObjectId != null) {
              commentId = commentObjectId.toString();
            }
            print(
              'Mention notification: mentionedUserId=$mentionedUserId, userId=$userId, commentId=$commentId',
            );
            if (mentionedUserId != null &&
                mentionedUserId != userId &&
                commentId != null) {
              final notificationDoc = {
                'userId': mentionedUserId,
                'type': 'mention',
                'commentId': commentId,
                'postId': postId,
                'byUserId': userId,
                'createdAt': DateTime.now().toIso8601String(),
                'read': false,
              };
              print('addComment: inserting notification: $notificationDoc');
              try {
                await _notificationsCollection!.insert(notificationDoc);
                print(
                  'addComment: Notification inserted for user: $mentionedUserId',
                );
              } catch (e) {
                print('addComment: Error inserting notification: $e');
              }
            }
          }
        }
      }

      return Comment.fromMap(commentData);
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  // Get comments for a post
  static Future<List<Comment>> getCommentsForPost(String postId) async {
    try {
      await _initializeDatabase();

      final cursor = await _commentsCollection!.find(
        where.eq('postId', postId).sortBy('createdAt', descending: false),
      );

      final List<Comment> comments = [];
      await for (final document in cursor) {
        comments.add(Comment.fromMap(document));
      }

      return comments;
    } catch (e) {
      print('Error getting comments for post: $e');
      return [];
    }
  }

  // Get comment count for a post
  static Future<int> getCommentCount(String postId) async {
    try {
      await _initializeDatabase();

      final count = await _commentsCollection!.count(
        where.eq('postId', postId),
      );

      return count;
    } catch (e) {
      print('Error getting comment count: $e');
      return 0;
    }
  }

  // Update a comment
  static Future<bool> updateComment(String commentId, String newContent) async {
    try {
      await _initializeDatabase();

      print(
        'Attempting to update comment: id=$commentId, newContent=$newContent',
      );

      // Handle both string and ObjectId formats
      ObjectId objectId;
      try {
        objectId = ObjectId.fromHexString(commentId);
        print('Successfully parsed ObjectId: $objectId');
      } catch (e) {
        print('Error parsing ObjectId from hex string: $e');
        // If it's already an ObjectId string, try to parse it differently
        try {
          objectId = ObjectId.parse(commentId);
          print('Successfully parsed ObjectId using parse: $objectId');
        } catch (parseError) {
          print('Error parsing ObjectId using parse: $parseError');
          return false;
        }
      }

      final result = await _commentsCollection!.update(
        where.eq('_id', objectId),
        modify
            .set('content', newContent)
            .set('updatedAt', DateTime.now().toIso8601String()),
      );

      print('Update result: $result');

      return true;
    } catch (e) {
      print('Error updating comment: $e');
      return false;
    }
  }

  // Delete a comment
  static Future<bool> deleteComment(String commentId, String userId) async {
    try {
      await _initializeDatabase();

      print('Attempting to delete comment: id=$commentId, userId=$userId');

      // Handle both string and ObjectId formats
      ObjectId objectId;
      try {
        objectId = ObjectId.fromHexString(commentId);
        print('Successfully parsed ObjectId: $objectId');
      } catch (e) {
        print('Error parsing ObjectId from hex string: $e');
        // If it's already an ObjectId string, try to parse it differently
        try {
          objectId = ObjectId.parse(commentId);
          print('Successfully parsed ObjectId using parse: $objectId');
        } catch (parseError) {
          print('Error parsing ObjectId using parse: $parseError');
          return false;
        }
      }

      final result = await _commentsCollection!.deleteOne(
        where.eq('_id', objectId).eq('userId', userId),
      );

      print('Delete result: $result');

      // Recursively delete all replies
      await _deleteRepliesRecursively(commentId);

      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  static Future<void> _deleteRepliesRecursively(String parentId) async {
    final replies = await _commentsCollection!
        .find(where.eq('parentId', parentId))
        .toList();
    for (final reply in replies) {
      final replyId = reply['_id']?.toHexString() ?? '';
      if (replyId.isNotEmpty) {
        await _commentsCollection!.deleteOne(where.eq('_id', reply['_id']));
        await _deleteRepliesRecursively(replyId);
      }
    }
  }

  // Get comments by user
  static Future<List<Comment>> getCommentsByUser(String userId) async {
    try {
      await _initializeDatabase();

      final cursor = await _commentsCollection!.find(
        where.eq('userId', userId).sortBy('createdAt', descending: true),
      );

      final List<Comment> comments = [];
      await for (final document in cursor) {
        comments.add(Comment.fromMap(document));
      }

      return comments;
    } catch (e) {
      print('Error getting comments by user: $e');
      return [];
    }
  }

  // --- COMMENT LIKE SYSTEM ---
  static Future<bool> likeComment(String userId, String commentId) async {
    await _initializeLikeDatabase();
    _notificationsCollection ??= _db!.collection('notifications');
    // Check if already liked
    final existing = await _likesCollection!.findOne({
      'userId': userId,
      'commentId': commentId,
    });
    if (existing != null) return false;
    // Add like
    await _likesCollection!.insert({
      'userId': userId,
      'commentId': commentId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    // Get comment to find author
    final comment = await _commentsCollection!.findOne({
      '_id': ObjectId.parse(commentId),
    });
    String? commentAuthorId;
    if (comment != null && comment['userId'] != null) {
      if (comment['userId'] is ObjectId) {
        commentAuthorId = comment['userId'].toHexString();
      } else {
        commentAuthorId = comment['userId'].toString();
      }
    }
    print(
      'likeComment: comment=$comment, commentAuthorId=$commentAuthorId, liker userId=$userId',
    );
    if (commentAuthorId != null && commentAuthorId != userId) {
      final notificationDoc = {
        'userId': commentAuthorId,
        'type': 'comment_like',
        'commentId': commentId,
        'byUserId': userId,
        'createdAt': DateTime.now().toIso8601String(),
        'read': false,
      };
      print('likeComment: inserting notification: $notificationDoc');
      try {
        await _notificationsCollection!.insert(notificationDoc);
        print('likeComment: Notification inserted for user: $commentAuthorId');
      } catch (e) {
        print('likeComment: Error inserting notification: $e');
      }
    }
    return true;
  }

  static Future<bool> unlikeComment(String userId, String commentId) async {
    await _initializeLikeDatabase();
    final result = await _likesCollection!.remove({
      'userId': userId,
      'commentId': commentId,
    });
    return result['n'] > 0;
  }

  static Future<int> getCommentLikeCount(String commentId) async {
    await _initializeLikeDatabase();
    return await _likesCollection!.count({'commentId': commentId});
  }

  static Future<bool> isCommentLikedByUser(
    String userId,
    String commentId,
  ) async {
    await _initializeLikeDatabase();
    final like = await _likesCollection!.findOne({
      'userId': userId,
      'commentId': commentId,
    });
    return like != null;
  }
}
