import 'package:equatable/equatable.dart';

import '../../../../core/models/user.dart';
import '../../../posts/data/models/post.dart';

class SearchState extends Equatable {
  const SearchState({
    this.posts = const [],
    this.users = const [],
    this.friendshipStatuses = const {},
    this.isLoading = false,
    this.selectedTab = 0,
    this.query = '',
    this.message,
    this.isSuccess = false,
  });

  final List<Post> posts;
  final List<User> users;
  final Map<int, String> friendshipStatuses;
  final bool isLoading;
  final int selectedTab;
  final String query;
  final String? message;
  final bool isSuccess;

  SearchState copyWith({
    List<Post>? posts,
    List<User>? users,
    Map<int, String>? friendshipStatuses,
    bool? isLoading,
    int? selectedTab,
    String? query,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return SearchState(
      posts: posts ?? this.posts,
      users: users ?? this.users,
      friendshipStatuses: friendshipStatuses ?? this.friendshipStatuses,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      query: query ?? this.query,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    users,
    friendshipStatuses,
    isLoading,
    selectedTab,
    query,
    message,
    isSuccess,
  ];
}
