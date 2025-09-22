class Album {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  Album({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['_id'] is String ? map['_id'] : map['_id'].toString(),
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
