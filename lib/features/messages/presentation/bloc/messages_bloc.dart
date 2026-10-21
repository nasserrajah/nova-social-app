import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/messages_repository.dart';
import 'messages_event.dart';
import 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc({required MessagesRepository repository})
    : _repository = repository,
      super(const MessagesState()) {
    on<MessagesLoadRequested>(_onLoadRequested);
    on<MessagesRefreshRequested>(_onLoadRequested);
    on<MessagesMessageCleared>(_onMessageCleared);
  }

  final MessagesRepository _repository;

  Future<void> _onLoadRequested(
    MessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    final isArabic = event is MessagesLoadRequested
        ? event.isArabic
        : (event as MessagesRefreshRequested).isArabic;

    emit(state.copyWith(isLoading: true, clearMessage: true));

    try {
      final currentUserId = await _repository.getCurrentUserId();
      final conversations = await _repository.getConversations(currentUserId);
      final friends = await _repository.getFriends();

      emit(
        state.copyWith(
          currentUserId: currentUserId,
          conversations: conversations,
          friends: friends,
          isLoading: false,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          message: error.message,
          isSuccess: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          message: isArabic ? 'خطأ في تحميل البيانات' : 'Error loading data',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(
    MessagesMessageCleared event,
    Emitter<MessagesState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
