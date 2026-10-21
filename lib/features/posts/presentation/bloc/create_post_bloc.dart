import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/posts_repository.dart';
import 'create_post_event.dart';
import 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  CreatePostBloc({required PostsRepository repository})
    : _repository = repository,
      super(const CreatePostState()) {
    on<CreatePostSubmitted>(_onSubmitted);
    on<CreatePostMessageCleared>(_onMessageCleared);
  }

  final PostsRepository _repository;

  Future<void> _onSubmitted(
    CreatePostSubmitted event,
    Emitter<CreatePostState> emit,
  ) async {
    final content = event.content.trim();

    if (content.isEmpty && event.image == null) {
      emit(
        CreatePostState(
          isSuccess: false,
          message: event.isArabic
              ? 'اكتب نصاً أو اختر صورة قبل النشر'
              : 'Write something or pick an image before posting',
        ),
      );
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, isSuccess: false, clearMessage: true),
    );

    try {
      await _repository.createPost(content: content, image: event.image);

      emit(
        CreatePostState(
          isSubmitting: false,
          isSuccess: true,
          message: event.isArabic ? 'تم النشر' : 'Post published',
        ),
      );
    } on ApiException catch (error) {
      emit(
        CreatePostState(
          isSubmitting: false,
          isSuccess: false,
          message: error.message,
        ),
      );
    } catch (error) {
      emit(
        CreatePostState(
          isSubmitting: false,
          isSuccess: false,
          message: event.isArabic
              ? 'حدث خطأ أثناء النشر: $error'
              : 'Something went wrong while posting: $error',
        ),
      );
    }
  }

  void _onMessageCleared(
    CreatePostMessageCleared event,
    Emitter<CreatePostState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
