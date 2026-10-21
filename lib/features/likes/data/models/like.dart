class Like {
  const Like({
    required this.id,
    required this.userId,
    required this.postId,
    required this.reaction,
    required this.createdAt,
    this.user,
    this.post,
  });

  final int id;
  final int userId;
  final int postId;
  final String reaction;
  final DateTime createdAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? post;

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      postId: _asInt(json['post_id']),
      reaction: json['reaction']?.toString() ?? 'like',
      createdAt: _asDate(json['created_at']),
      user: json['user'] is Map
          ? Map<String, dynamic>.from(json['user'] as Map)
          : null,
      post: json['post'] is Map
          ? Map<String, dynamic>.from(json['post'] as Map)
          : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _asDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
