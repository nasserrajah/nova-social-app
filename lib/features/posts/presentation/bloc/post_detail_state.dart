import 'package:equatable/equatable.dart';

class PostDetailState extends Equatable {
  const PostDetailState({
    this.post,
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
  });

  final Map<String, dynamic>? post;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  PostDetailState copyWith({
    Map<String, dynamic>? post,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [post, isLoading, message, isSuccess];
}
