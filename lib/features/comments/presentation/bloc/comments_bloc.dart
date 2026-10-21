import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/comments_repository.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc({required CommentsRepository repository})
    : _repository = repository,
      super(const CommentsState()) {
    on<CommentsLoadRequested>(_onLoadRequested);
    on<CommentSubmitted>(_onSubmitted);
    on<CommentDeleteRequested>(_onDeleteRequested);
    on<CommentsMessageCleared>(_onMessageCleared);
  }

  final CommentsRepository _repository;

  Future<void> _onLoadRequested(
    CommentsLoadRequested event,
    Emitter<CommentsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));

    try {
      final comments = await _repository.getComments(event.postId);
      emit(state.copyWith(comments: comments, isLoading: false));
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
          message: event.isArabic
              ? 'فشل تحميل التعليقات: $error'
              : 'Failed to load comments: $error',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    CommentSubmitted event,
    Emitter<CommentsState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty) return;

    emit(state.copyWith(isSubmitting: true, clearMessage: true));

    try {
      final comment = await _repository.addComment(
        postId: event.postId,
        content: content,
      );

      emit(
        state.copyWith(
          comments: [comment, ...state.comments],
          isSubmitting: false,
          message: event.isArabic ? 'تم إضافة التعليق' : 'Comment added',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          message: error.message,
          isSuccess: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          message: event.isArabic
              ? 'فشل إضافة التعليق: $error'
              : 'Failed to add comment: $error',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    CommentDeleteRequested event,
    Emitter<CommentsState> emit,
  ) async {
    try {
      await _repository.deleteComment(event.commentId);

      emit(
        state.copyWith(
          comments: state.comments
              .where((comment) => comment.id != event.commentId)
              .toList(),
          message: event.isArabic ? 'تم حذف التعليق' : 'Comment deleted',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (error) {
      emit(
        state.copyWith(
          message: event.isArabic
              ? 'فشل حذف التعليق: $error'
              : 'Failed to delete comment: $error',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(
    CommentsMessageCleared event,
    Emitter<CommentsState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
