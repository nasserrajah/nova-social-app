import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/likes_repository.dart';
import 'likes_event.dart';
import 'likes_state.dart';

class LikesBloc extends Bloc<LikesEvent, LikesState> {
  LikesBloc({required LikesRepository repository})
    : _repository = repository,
      super(const LikesState()) {
    on<LikesLoadRequested>(_onLoadRequested);
    on<LikeRemovalRequested>(_onRemovalRequested);
    on<LikesMessageCleared>(_onMessageCleared);
  }

  final LikesRepository _repository;

  Future<void> _onLoadRequested(
    LikesLoadRequested event,
    Emitter<LikesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));

    try {
      final likes = await _repository.getLikes();
      emit(state.copyWith(likes: likes, isLoading: false));
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
              ? 'فشل تحميل المفضلة: $error'
              : 'Failed to load likes: $error',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onRemovalRequested(
    LikeRemovalRequested event,
    Emitter<LikesState> emit,
  ) async {
    try {
      await _repository.removeLike(event.likeId);
      emit(
        state.copyWith(
          likes: state.likes.where((like) => like.id != event.likeId).toList(),
          message: event.isArabic
              ? 'تم حذف المنشور من المفضلة'
              : 'Removed from favorites',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (error) {
      emit(
        state.copyWith(
          message: event.isArabic ? 'خطأ: $error' : 'Error: $error',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(LikesMessageCleared event, Emitter<LikesState> emit) {
    emit(state.copyWith(clearMessage: true));
  }
}
