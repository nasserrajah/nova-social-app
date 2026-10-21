import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  /// Whether user-facing messages should be shown in Arabic.
  bool get isArabic => false;

  @override
  List<Object?> get props => [];
}

class PostsLoadRequested extends PostsEvent {
  const PostsLoadRequested({this.isArabic = false});

  @override
  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class PostsRefreshRequested extends PostsEvent {
  const PostsRefreshRequested({this.isArabic = false});

  @override
  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class PostReactionSelected extends PostsEvent {
  const PostReactionSelected({
    required this.postId,
    required this.emoji,
    this.isArabic = false,
  });

  final int postId;
  final String emoji;

  @override
  final bool isArabic;

  @override
  List<Object?> get props => [postId, emoji, isArabic];
}

class PostsMessageCleared extends PostsEvent {
  const PostsMessageCleared();
}
