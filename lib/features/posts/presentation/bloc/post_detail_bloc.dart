import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/posts_repository.dart';
import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({required PostsRepository repository})
    : _repository = repository,
      super(const PostDetailState()) {
    on<PostDetailRequested>(_onRequested);
    on<PostDetailMessageCleared>(_onMessageCleared);
  }

  final PostsRepository _repository;

  Future<void> _onRequested(
    PostDetailRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));

    try {
      final post = await _repository.getPostDetails(event.postId);
      emit(state.copyWith(post: post.toJson(), isLoading: false));
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          message: error.message,
          isSuccess: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Error loading post: $error',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(
    PostDetailMessageCleared event,
    Emitter<PostDetailState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
