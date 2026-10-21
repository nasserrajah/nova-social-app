import 'package:equatable/equatable.dart';

import '../../../../core/models/user.dart';
import '../../data/models/chat_message.dart';

class MessagesState extends Equatable {
  const MessagesState({
    this.conversations = const [],
    this.friends = const [],
    this.currentUserId,
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
  });

  final List<Conversation> conversations;
  final List<User> friends;
  final int? currentUserId;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  MessagesState copyWith({
    List<Conversation>? conversations,
    List<User>? friends,
    int? currentUserId,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      friends: friends ?? this.friends,
      currentUserId: currentUserId ?? this.currentUserId,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    friends,
    currentUserId,
    isLoading,
    message,
    isSuccess,
  ];
}
