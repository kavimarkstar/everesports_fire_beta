class User {
  final String id;
  final String userId;
  final String name;
  final String username;
  final String profileImageUrl;

  User({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    required this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json.containsKey('_id')) {
      final obj = json['_id'];
      if (obj is String) {
        id = obj;
      } else if (obj is Map && obj.containsKey('\$oid')) {
        id = obj['\$oid'];
      } else if (obj.runtimeType.toString() == 'ObjectId') {
        id = obj.toHexString();
      }
    } else if (json.containsKey('id')) {
      id = json['id'];
    }
    return User(
      id: id,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}
