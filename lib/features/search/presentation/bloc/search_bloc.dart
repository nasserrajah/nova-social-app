import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../posts/data/models/post.dart';
import '../../data/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository repository})
    : _repository = repository,
      super(const SearchState()) {
    on<SearchSubmitted>(_onSubmitted);
    on<SearchTabChanged>(_onTabChanged);
    on<SearchFriendRequestSent>(_onFriendRequestSent);
    on<SearchCleared>(_onCleared);
    on<SearchMessageCleared>(_onMessageCleared);
  }

  final SearchRepository _repository;

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          posts: const <Post>[],
          users: const [],
          query: '',
          isLoading: false,
        ),
      );
      return;
    }

    await _runSearch(
      emit,
      query: query,
      index: event.searchUsers ? 1 : 0,
      isArabic: event.isArabic,
    );
  }

  Future<void> _onTabChanged(
    SearchTabChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(state.copyWith(selectedTab: event.index));
      return;
    }

    await _runSearch(
      emit,
      query: query,
      index: event.index,
      isArabic: event.isArabic,
    );
  }

  Future<void> _runSearch(
    Emitter<SearchState> emit, {
    required String query,
    required int index,
    required bool isArabic,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        query: query,
        selectedTab: index,
        clearMessage: true,
      ),
    );

    try {
      if (index == 0) {
        final posts = await _repository.searchPosts(query);
        emit(state.copyWith(posts: posts, users: const [], isLoading: false));
      } else {
        final users = await _repository.searchUsers(query);
        final statuses = await _repository.getFriendshipStatuses(users);
        emit(
          state.copyWith(
            users: users,
            posts: const <Post>[],
            friendshipStatuses: statuses,
            isLoading: false,
          ),
        );
      }
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
          message: isArabic ? 'خطأ في البحث' : 'Search error',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onFriendRequestSent(
    SearchFriendRequestSent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.sendFriendRequest(event.userId);

      final statuses = Map<int, String>.from(state.friendshipStatuses);
      statuses[event.userId] = 'request_sent';

      emit(
        state.copyWith(
          friendshipStatuses: statuses,
          message: event.isArabic
              ? 'تم إرسال طلب الصداقة'
              : 'Friend request sent',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (_) {
      emit(
        state.copyWith(
          message: event.isArabic
              ? 'خطأ في إرسال طلب الصداقة'
              : 'Error sending friend request',
          isSuccess: false,
        ),
      );
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }

  void _onMessageCleared(
    SearchMessageCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
