import 'package:equatable/equatable.dart';

import '../../data/models/comment.dart';

class CommentsState extends Equatable {
  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.message,
    this.isSuccess = false,
  });

  final List<Comment> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? message;
  final bool isSuccess;

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    comments,
    isLoading,
    isSubmitting,
    message,
    isSuccess,
  ];
}
