import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class CommentsLoadRequested extends CommentsEvent {
  const CommentsLoadRequested(this.postId, {this.isArabic = false});

  final int postId;
  final bool isArabic;

  @override
  List<Object?> get props => [postId, isArabic];
}

class CommentSubmitted extends CommentsEvent {
  const CommentSubmitted({
    required this.postId,
    required this.content,
    this.isArabic = false,
  });

  final int postId;
  final String content;
  final bool isArabic;

  @override
  List<Object?> get props => [postId, content, isArabic];
}

class CommentDeleteRequested extends CommentsEvent {
  const CommentDeleteRequested(this.commentId, {this.isArabic = false});

  final int commentId;
  final bool isArabic;

  @override
  List<Object?> get props => [commentId, isArabic];
}

class CommentsMessageCleared extends CommentsEvent {
  const CommentsMessageCleared();
}
