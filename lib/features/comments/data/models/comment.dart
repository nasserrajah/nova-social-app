class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  final int id;
  final int userId;
  final int postId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? user;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      postId: _asInt(json['post_id']),
      content: json['content']?.toString() ?? '',
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
      user: json['user'] is Map
          ? Map<String, dynamic>.from(json['user'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user,
    };
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
