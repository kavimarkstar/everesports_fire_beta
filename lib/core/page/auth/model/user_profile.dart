class UserProfile {
  final String? id; // Firestore document ID
  final String? userId;
  final String? username;
  final String? name;
  final String? email;
  final String? birthday;
  final String? password;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isVerified;
  final bool? isPremium;
  final Map<String, dynamic>? socialLinks;
  final List<String>? interests;
  final Map<String, dynamic>? settings;

  UserProfile({
    this.id,
    this.userId,
    this.username,
    this.name,
    this.email,
    this.birthday,
    this.password,
    this.profileImageUrl,
    this.coverImageUrl,
    this.createdAt,
    this.updatedAt,
    this.isVerified,
    this.isPremium,
    this.socialLinks,
    this.interests,
    this.settings,
  });

  /// Create a UserProfile from a Firestore map (document snapshot data)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id:
          map['docId']?.toString() ??
          map['id']?.toString() ??
          map['_id']?.toString(),
      userId: map['userId']?.toString(),
      username: map['username']?.toString(),
      name: map['name']?.toString(),
      email: map['email']?.toString(),
      birthday: map['birthday']?.toString(),
      password: map['password']?.toString(),
      profileImageUrl:
          map['profileImageUrl']?.toString() ??
          map['profileImageBase64']?.toString(),
      coverImageUrl:
          map['coverImageUrl']?.toString() ??
          map['coverImageBase64']?.toString(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
                ? map['createdAt']
                : DateTime.tryParse(map['createdAt'].toString()))
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
                ? map['updatedAt']
                : DateTime.tryParse(map['updatedAt'].toString()))
          : null,
      isVerified: map['isVerified'] as bool? ?? false,
      isPremium: map['isPremium'] as bool? ?? false,
      socialLinks: map['socialLinks'] is Map<String, dynamic>
          ? map['socialLinks'] as Map<String, dynamic>
          : {},
      interests: map['interests'] != null
          ? List<String>.from(map['interests'] as List)
          : [],
      settings: map['settings'] is Map<String, dynamic>
          ? map['settings'] as Map<String, dynamic>
          : {},
    );
  }

  /// Convert UserProfile to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (birthday != null) 'birthday': birthday,
      if (password != null) 'password': password,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isVerified': isVerified ?? false,
      'isPremium': isPremium ?? false,
      'socialLinks': socialLinks ?? {},
      'interests': interests ?? [],
      'settings': settings ?? {},
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? username,
    String? name,
    String? email,
    String? birthday,
    String? password,
    String? profileImageUrl,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isPremium,
    Map<String, dynamic>? socialLinks,
    List<String>? interests,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      password: password ?? this.password,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      socialLinks: socialLinks ?? this.socialLinks,
      interests: interests ?? this.interests,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, userId: $userId, username: $username, name: $name, email: $email, birthday: $birthday, password: $password, profileImageUrl: $profileImageUrl, coverImageUrl: $coverImageUrl, createdAt: $createdAt, updatedAt: $updatedAt, isVerified: $isVerified, isPremium: $isPremium, socialLinks: $socialLinks, interests: $interests, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.name == name &&
        other.email == email &&
        other.birthday == birthday &&
        other.password == password &&
        other.profileImageUrl == profileImageUrl &&
        other.coverImageUrl == coverImageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isVerified == isVerified &&
        other.isPremium == isPremium &&
        other.socialLinks == socialLinks &&
        other.interests == interests &&
        other.settings == settings;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        username.hashCode ^
        name.hashCode ^
        email.hashCode ^
        birthday.hashCode ^
        password.hashCode ^
        profileImageUrl.hashCode ^
        coverImageUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isVerified.hashCode ^
        isPremium.hashCode ^
        socialLinks.hashCode ^
        interests.hashCode ^
        settings.hashCode;
  }
}
