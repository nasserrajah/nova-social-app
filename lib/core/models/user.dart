/// Shared user model used by auth, profile, search and messages.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.avatar,
    this.coverImage,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.friendsCount,
  });

  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final String? avatar;
  final String? coverImage;
  final String? bio;
  final String? createdAt;
  final String? updatedAt;
  final int? friendsCount;

  factory User.fromJson(Map<String, dynamic> json) {
    final image = json['profile_image'] ?? json['avatar'];

    return User(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage: image?.toString(),
      avatar: image?.toString(),
      coverImage: json['cover_image']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      friendsCount: json['friends_count'] == null
          ? null
          : _asInt(json['friends_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'avatar': avatar,
      'cover_image': coverImage,
      'bio': bio,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'friends_count': friendsCount,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? profileImage,
    String? coverImage,
    String? bio,
    int? friendsCount,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      avatar: profileImage ?? avatar,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
      friendsCount: friendsCount ?? this.friendsCount,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
