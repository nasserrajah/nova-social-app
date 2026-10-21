import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatLoadRequested extends ChatEvent {
  const ChatLoadRequested({required this.friendId, this.isArabic = false});

  final int friendId;
  final bool isArabic;

  @override
  List<Object?> get props => [friendId, isArabic];
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({
    required this.friendId,
    required this.text,
    this.isArabic = false,
  });

  final int friendId;
  final String text;
  final bool isArabic;

  @override
  List<Object?> get props => [friendId, text, isArabic];
}

class ChatMessageCleared extends ChatEvent {
  const ChatMessageCleared();
}
