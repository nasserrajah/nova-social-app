import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/post.dart';
import '../../data/repositories/posts_repository.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc({required PostsRepository repository})
    : _repository = repository,
      super(const PostsState()) {
    on<PostsLoadRequested>(_onLoadRequested);
    on<PostsRefreshRequested>(_onLoadRequested);
    on<PostReactionSelected>(_onReactionSelected);
    on<PostsMessageCleared>(_onMessageCleared);
  }

  final PostsRepository _repository;

  Future<void> _onLoadRequested(
    PostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearMessage: true));

    try {
      final token = await _repository.getToken();
      final userId = await _repository.getCurrentUserId();
      final posts = await _repository.getPosts();

      final likedStatus = <int, bool>{};
      final reactions = <int, String?>{};
      final likesCount = <int, int>{};

      for (final post in posts) {
        final userLike = _findUserLike(post, userId);
        final isLiked = userLike != null;

        likedStatus[post.id] = isLiked;
        reactions[post.id] = userLike == null
            ? null
            : (userLike['reaction']?.toString() ?? '❤️');
        likesCount[post.id] = post.likesCount;
      }

      emit(
        state.copyWith(
          posts: posts,
          isLoading: false,
          currentUserId: userId,
          likedStatus: likedStatus,
          reactions: reactions,
          likesCount: likesCount,
          clearError: true,
          clearMessage: true,
          token: token,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          error: error.message,
          actionMessage: error.message,
          actionSuccess: false,
        ),
      );
    } catch (error) {
      final message = event.isArabic
          ? 'حدث خطأ: $error'
          : 'An error occurred: $error';
      emit(
        state.copyWith(
          isLoading: false,
          error: message,
          actionMessage: message,
          actionSuccess: false,
        ),
      );
    }
  }

  Future<void> _onReactionSelected(
    PostReactionSelected event,
    Emitter<PostsState> emit,
  ) async {
    try {
      final result = await _repository.toggleReaction(
        postId: event.postId,
        reaction: event.emoji,
      );

      final likedStatus = Map<int, bool>.from(state.likedStatus);
      final reactions = Map<int, String?>.from(state.reactions);
      final likesCount = Map<int, int>.from(state.likesCount);

      likedStatus[event.postId] = result.liked;
      reactions[event.postId] = result.liked ? event.emoji : null;
      likesCount[event.postId] = result.likesCount;

      emit(
        state.copyWith(
          likedStatus: likedStatus,
          reactions: reactions,
          likesCount: likesCount,
          actionMessage: result.message,
          actionSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(actionMessage: error.message, actionSuccess: false));
    } catch (error) {
      emit(
        state.copyWith(
          actionMessage: event.isArabic
              ? 'خطأ في الشبكة: $error'
              : 'Network error: $error',
          actionSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(PostsMessageCleared event, Emitter<PostsState> emit) {
    emit(state.copyWith(clearMessage: true));
  }

  Map<String, dynamic>? _findUserLike(Post post, int? userId) {
    if (userId == null || post.likes == null) return null;

    for (final like in post.likes!) {
      if (like is Map && _asInt(like['user_id']) == userId) {
        return Map<String, dynamic>.from(like);
      }
    }
    return null;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
