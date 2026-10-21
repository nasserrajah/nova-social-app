class Post {
  const Post({
    required this.id,
    this.content,
    this.image,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.likes,
    this.comments,
    required this.likesCount,
    required this.commentsCount,
    this.viewsCount = 0,
  });

  final int id;
  final String? content;
  final String? image;
  final Map<String, dynamic>? user;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic>? likes;
  final List<dynamic>? comments;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: _asInt(json['id']),
      content: json['content']?.toString(),
      image: json['image']?.toString(),
      user: json['user'] is Map
          ? Map<String, dynamic>.from(json['user'] as Map)
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      likes: json['likes'] is List ? json['likes'] as List : null,
      comments: json['comments'] is List ? json['comments'] as List : null,
      likesCount: _asInt(json['likes_count']),
      commentsCount: _asInt(json['comments_count']),
      viewsCount: _asInt(json['views_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'image': image,
      'user': user,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'likes': likes,
      'comments': comments,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'views_count': viewsCount,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
