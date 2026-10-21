import 'package:equatable/equatable.dart';

import '../../data/models/post.dart';

class PostsState extends Equatable {
  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.currentUserId,
    this.likedStatus = const {},
    this.reactions = const {},
    this.likesCount = const {},
    this.actionMessage,
    this.actionSuccess = false,
    this.token,
  });

  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final int? currentUserId;
  final Map<int, bool> likedStatus;
  final Map<int, String?> reactions;
  final Map<int, int> likesCount;
  final String? actionMessage;
  final bool actionSuccess;
  final String? token;

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    int? currentUserId,
    Map<int, bool>? likedStatus,
    Map<int, String?>? reactions,
    Map<int, int>? likesCount,
    String? actionMessage,
    bool? actionSuccess,
    String? token,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentUserId: currentUserId ?? this.currentUserId,
      likedStatus: likedStatus ?? this.likedStatus,
      reactions: reactions ?? this.reactions,
      likesCount: likesCount ?? this.likesCount,
      actionMessage: clearMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      actionSuccess: actionSuccess ?? this.actionSuccess,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    isLoading,
    error,
    currentUserId,
    likedStatus,
    reactions,
    likesCount,
    actionMessage,
    actionSuccess,
    token,
  ];
}
