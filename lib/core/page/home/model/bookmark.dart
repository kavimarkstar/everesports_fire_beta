class Bookmark {
  final String id;
  final String userId;
  final String postId;
  final String albumId;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.postId,
    required this.albumId,
    required this.createdAt,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['_id'] is String ? map['_id'] : map['_id'].toString(),
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      albumId: map['albumId'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postId': postId,
      'albumId': albumId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
