import 'package:equatable/equatable.dart';

import '../../data/models/chat_message.dart';

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.currentUserId,
    this.isLoading = false,
    this.isSending = false,
    this.message,
    this.isSuccess = false,
  });

  final List<ChatMessage> messages;
  final int? currentUserId;
  final bool isLoading;
  final bool isSending;
  final String? message;
  final bool isSuccess;

  ChatState copyWith({
    List<ChatMessage>? messages,
    int? currentUserId,
    bool? isLoading,
    bool? isSending,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    currentUserId,
    isLoading,
    isSending,
    message,
    isSuccess,
  ];
}
