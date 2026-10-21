import 'package:equatable/equatable.dart';

import '../../data/models/like.dart';

class LikesState extends Equatable {
  const LikesState({
    this.likes = const [],
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
  });

  final List<Like> likes;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  LikesState copyWith({
    List<Like>? likes,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return LikesState(
      likes: likes ?? this.likes,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [likes, isLoading, message, isSuccess];
}
