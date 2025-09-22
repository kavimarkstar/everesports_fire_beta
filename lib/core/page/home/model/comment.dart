import 'package:mongo_dart/mongo_dart.dart';

class Comment {
  final String id;
  final String userId;
  final String postId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    String id;
    if (map['_id'] is ObjectId) {
      id = (map['_id'] as ObjectId).toHexString();
    } else if (map['_id'] is String && map['_id'].startsWith('ObjectId(')) {
      // Extract hex string from 'ObjectId("...")'
      final match = RegExp(
        'ObjectId\(["\']?([a-fA-F0-9]{24})["\']?\)',
      ).firstMatch(map['_id']);
      id = match != null ? match.group(1)! : map['_id'];
    } else {
      id = map['_id'].toString();
    }
    return Comment(
      id: id,
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      parentId: map['parentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postId': postId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (parentId != null) 'parentId': parentId,
    };
  }
}
