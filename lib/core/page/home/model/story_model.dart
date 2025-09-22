class Story {
  final String id;
  final String userId;
  final String imagePath;
  final String? description;
  final String? uploadTime;
  final Map<String, dynamic>? location;

  Story({
    required this.id,
    required this.userId,
    required this.imagePath,
    this.description,
    this.uploadTime,
    this.location,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id']?.toString() ?? '',
      userId: json['userId'] ?? '',
      imagePath: json['imagePath'] ?? '',
      description: json['description'],
      uploadTime: json['uploadTime'],
      location: json['location'] != null
          ? Map<String, dynamic>.from(json['location'])
          : null,
    );
  }
}
