import 'package:everesports/core/page/home/model/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  static final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // Add a comment to a post
  static Future<Comment?> addComment(
    String userId,
    String postId,
    String content, [
    String? parentId,
  ]) async {
    try {
      final data = {
        'userId': userId,
        'postId': postId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'view': false,
        if (parentId != null) 'parentId': parentId,
      };
      final doc = await _fs.collection('comments').add(data);
      final createdAt = DateTime.now();

      // Insert notification for post owner in 'notification_comments'
      try {
        String ownerId = '';
        Map<String, dynamic>? postData;
        final postDoc = await _fs.collection('posts').doc(postId).get();
        if (postDoc.exists) {
          postData = postDoc.data();
        } else {
          // Fallback if postId isn't a doc id: try querying by a field named 'postId'
          final alt = await _fs
              .collection('posts')
              .where('postId', isEqualTo: postId)
              .limit(1)
              .get();
          if (alt.docs.isNotEmpty) {
            postData = alt.docs.first.data();
          }
        }
        ownerId = postData != null
            ? (postData['userId']?.toString() ?? '')
            : '';

        if (ownerId.isNotEmpty && ownerId != userId) {
          await _fs.collection('notification_comments').add({
            'type': 'comment',
            'userId': ownerId, // notification recipient (post owner)
            'postId': postId,
            'commentId': doc.id,
            'byUserId': userId, // commenter
            'content': content,
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
            'view': false,
          });
        }

        // Mention notification logic
        final mentionRegExp = RegExp(r'@(\w+)');
        final matches = mentionRegExp.allMatches(content);
        for (final match in matches) {
          final username = match.group(1);
          if (username != null) {
            // Find user by username
            final userQuery = await _fs
                .collection('users')
                .where('username', isEqualTo: username)
                .limit(1)
                .get();
            if (userQuery.docs.isNotEmpty) {
              final mentionedUser = userQuery.docs.first;
              final mentionedUserId = mentionedUser.id;
              if (mentionedUserId != userId) {
                await _fs.collection('notification_comments').add({
                  'type': 'mention',
                  'userId': mentionedUserId,
                  'commentId': doc.id,
                  'postId': postId,
                  'byUserId': userId,
                  'content': content,
                  'createdAt': FieldValue.serverTimestamp(),
                  'read': false,
                  'view': false,
                });
              }
            }
          }
        }
      } catch (e) {
        print('Firestore addComment notification error: $e');
      }
      return Comment(
        id: doc.id,
        userId: userId,
        postId: postId,
        content: content,
        createdAt: createdAt,
        updatedAt: createdAt,
        parentId: parentId,
      );
    } catch (e) {
      print('Firestore addComment error: $e');
      return null;
    }
  }

  // Get comments for a post
  static Future<List<Comment>> getCommentsForPost(String postId) async {
    try {
      final q = await _fs
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();
      final list = q.docs.map((d) {
        final m = d.data();
        final tsCreated = m['createdAt'];
        final tsUpdated = m['updatedAt'];
        return Comment(
          id: d.id,
          userId: (m['userId'] ?? '').toString(),
          postId: (m['postId'] ?? '').toString(),
          content: (m['content'] ?? '').toString(),
          createdAt: tsCreated is Timestamp
              ? tsCreated.toDate()
              : DateTime.now(),
          updatedAt: tsUpdated is Timestamp
              ? tsUpdated.toDate()
              : DateTime.now(),
          parentId: (m['parentId'] as String?),
        );
      }).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    } catch (e) {
      print('Firestore getCommentsForPost error: $e');
      return [];
    }
  }

  // Get comment count for a post
  static Future<int> getCommentCount(String postId) async {
    try {
      final q = await _fs
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Firestore getCommentCount error: $e');
      return 0;
    }
  }

  // Update a comment
  static Future<bool> updateComment(String commentId, String newContent) async {
    try {
      await _fs.collection('comments').doc(commentId).update({
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Firestore updateComment error: $e');
      return false;
    }
  }

  // Delete a comment and its replies
  static Future<bool> deleteComment(String commentId, String userId) async {
    try {
      await _fs.collection('comments').doc(commentId).delete();
      // delete replies (shallow)
      final replies = await _fs
          .collection('comments')
          .where('parentId', isEqualTo: commentId)
          .get();
      for (final d in replies.docs) {
        await d.reference.delete();
      }
      return true;
    } catch (e) {
      print('Firestore deleteComment error: $e');
      return false;
    }
  }

  // Get comments by user
  static Future<List<Comment>> getCommentsByUser(String userId) async {
    try {
      final q = await _fs
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final list = q.docs.map((d) {
        final m = d.data();
        final tsCreated = m['createdAt'];
        final tsUpdated = m['updatedAt'];
        return Comment(
          id: d.id,
          userId: (m['userId'] ?? '').toString(),
          postId: (m['postId'] ?? '').toString(),
          content: (m['content'] ?? '').toString(),
          createdAt: tsCreated is Timestamp
              ? tsCreated.toDate()
              : DateTime.now(),
          updatedAt: tsUpdated is Timestamp
              ? tsUpdated.toDate()
              : DateTime.now(),
          parentId: (m['parentId'] as String?),
        );
      }).toList();
      return list;
    } catch (e) {
      print('Firestore getCommentsByUser error: $e');
      return [];
    }
  }

  // --- COMMENT LIKE SYSTEM (Firestore) ---
  static Future<bool> likeComment(String userId, String commentId) async {
    try {
      final docId = '${userId}_${commentId}';
      final ref = _fs.collection('comments_like').doc(docId);
      final exists = await ref.get();
      if (exists.exists) return false;
      await ref.set({
        'userId': userId,
        'commentId': commentId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Get comment to find author
      final commentDoc = await _fs.collection('comments').doc(commentId).get();
      String? commentAuthorId;
      if (commentDoc.exists) {
        final data = commentDoc.data();
        if (data != null && data['userId'] != null) {
          commentAuthorId = data['userId'].toString();
        }
      }
      if (commentAuthorId != null && commentAuthorId != userId) {
        await _fs.collection('notification_comments').add({
          'type': 'comment_like',
          'userId': commentAuthorId,
          'commentId': commentId,
          'byUserId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
          'view': false,
        });
      }

      return true;
    } catch (e) {
      print('Firestore likeComment error: $e');
      return false;
    }
  }

  static Future<bool> unlikeComment(String userId, String commentId) async {
    try {
      final docId = '${userId}_${commentId}';
      await _fs.collection('comments_like').doc(docId).delete();
      return true;
    } catch (e) {
      print('Firestore unlikeComment error: $e');
      return false;
    }
  }

  static Future<int> getCommentLikeCount(String commentId) async {
    try {
      final q = await _fs
          .collection('comments_like')
          .where('commentId', isEqualTo: commentId)
          .get();
      return q.docs.length;
    } catch (e) {
      print('Firestore getCommentLikeCount error: $e');
      return 0;
    }
  }

  static Future<bool> isCommentLikedByUser(
    String userId,
    String commentId,
  ) async {
    try {
      final docId = '${userId}_${commentId}';
      final snap = await _fs.collection('comments_like').doc(docId).get();
      return snap.exists;
    } catch (e) {
      print('Firestore isCommentLikedByUser error: $e');
      return false;
    }
  }
}
