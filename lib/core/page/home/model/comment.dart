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

  /// Factory to create a Comment from a Firestore map (document snapshot data)
  factory Comment.fromMap(Map<String, dynamic> map) {
    // Firestore document id can be in 'id', 'docId', or '_id'
    String id =
        map['docId']?.toString() ??
        map['id']?.toString() ??
        map['_id']?.toString() ??
        '';
    return Comment(
      id: id,
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      parentId: map['parentId'],
    );
  }

  /// Convert Comment to a Firestore-compatible map
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
