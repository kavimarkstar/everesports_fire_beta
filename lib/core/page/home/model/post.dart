class Post {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> files;
  final List<String> mentions;
  final List<String> hashtags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> sharedUserIds;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.files,
    required this.mentions,
    required this.hashtags,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.sharedUserIds = const [],
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['_id'] is String ? map['_id'] : map['_id'].toString(),
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      files: List<String>.from(map['files'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
      hashtags: List<String>.from(map['hashtags'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      sharedUserIds: List<String>.from(map['sharedUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'files': files,
      'mentions': mentions,
      'hashtags': hashtags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'sharedUserIds': sharedUserIds,
    };
  }
}
