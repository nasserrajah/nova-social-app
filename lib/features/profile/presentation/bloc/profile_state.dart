import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.user,
    this.posts = const [],
    this.friendshipStatus,
    this.isLoading = false,
    this.isUploading = false,
    this.message,
    this.isSuccess = false,
  });

  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>> posts;
  final String? friendshipStatus;
  final bool isLoading;
  final bool isUploading;
  final String? message;
  final bool isSuccess;

  ProfileState copyWith({
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? posts,
    String? friendshipStatus,
    bool? isLoading,
    bool? isUploading,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      friendshipStatus: friendshipStatus ?? this.friendshipStatus,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    user,
    posts,
    friendshipStatus,
    isLoading,
    isUploading,
    message,
    isSuccess,
  ];
}
