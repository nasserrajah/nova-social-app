import '../../../../core/models/user.dart';

class Conversation {
  const Conversation({
    required this.otherUser,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final User otherUser;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final DateTime updatedAt;

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    return Conversation(
      otherUser: User.fromJson(
        json['other_user'] is Map
            ? Map<String, dynamic>.from(json['other_user'] as Map)
            : const <String, dynamic>{},
      ),
      lastMessage: json['last_message'] is Map
          ? ChatMessage.fromJson(
              Map<String, dynamic>.from(json['last_message'] as Map),
              currentUserId: currentUserId,
            )
          : null,
      unreadCount: _asInt(json['unread_count']),
      isOnline: json['is_online'] == true,
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.isRead,
  });

  final String text;
  final bool isMe;
  final DateTime time;
  final bool isRead;

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    final senderId = json['sender_id'];
    final isMe =
        json['is_me'] == true ||
        (currentUserId != null && senderId == currentUserId);

    return ChatMessage(
      text: json['message']?.toString() ?? '',
      isMe: isMe,
      time:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] != false,
    );
  }

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      text: text,
      isMe: isMe,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }
}
