class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.type,
    required this.message,
    required this.read,
    required this.createdAt,
    this.postId,
    this.fromUser,
    this.post,
  });

  final int id;
  final int userId;
  final int fromUserId;
  final int? postId;
  final String type;
  final String message;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? fromUser;
  final Map<String, dynamic>? post;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      fromUserId: _asInt(json['from_user_id']),
      postId: json['post_id'] == null ? null : _asInt(json['post_id']),
      type: json['type']?.toString() ?? 'general',
      message: json['message']?.toString() ?? '',
      read: _asBool(json['read']),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      fromUser: json['from_user'] is Map
          ? Map<String, dynamic>.from(json['from_user'] as Map)
          : null,
      post: json['post'] is Map
          ? Map<String, dynamic>.from(json['post'] as Map)
          : null,
    );
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      userId: userId,
      fromUserId: fromUserId,
      postId: postId,
      type: type,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
      fromUser: fromUser,
      post: post,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }
}
