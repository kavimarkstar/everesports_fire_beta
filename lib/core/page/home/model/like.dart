class Like {
  final String id;
  final String userId;
  final String postId;
  final String ownerUserId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.userId,
    required this.postId,
    required this.ownerUserId,
    required this.createdAt,
  });

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['_id'] is String ? map['_id'] : map['_id'].toString(),
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      ownerUserId: map['ownerUserId'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postId': postId,
      'ownerUserId': ownerUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
