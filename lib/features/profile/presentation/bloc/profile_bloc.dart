import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository, this.userId})
    : _repository = repository,
      super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
    on<ProfileImageUploadRequested>(_onImageUploadRequested);
    on<ProfileImageDeleteRequested>(_onImageDeleteRequested);
    on<ProfileFriendRequestSent>(_onFriendRequestSent);
    on<ProfileFriendRequestAccepted>(_onFriendRequestAccepted);
    on<ProfilePostDeleteRequested>(_onPostDeleteRequested);
    on<ProfileMessageCleared>(_onMessageCleared);
  }

  final ProfileRepository _repository;

  /// `null` means the signed-in user's own profile.
  final int? userId;

  bool get isOwnProfile => userId == null;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _load(emit, isArabic: event.isArabic, showSpinner: true);
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _load(
      emit,
      isArabic: event.isArabic,
      showSpinner: state.user == null,
    );
  }

  Future<void> _load(
    Emitter<ProfileState> emit, {
    required bool isArabic,
    required bool showSpinner,
  }) async {
    emit(state.copyWith(isLoading: showSpinner, clearMessage: true));

    try {
      final result = await _repository.getProfile(userId: userId);
      String? friendshipStatus;

      if (!isOwnProfile) {
        friendshipStatus = await _repository.getFriendshipStatus(userId!);
      }

      emit(
        state.copyWith(
          user: result.user,
          posts: result.posts,
          friendshipStatus: friendshipStatus,
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
          message: isArabic
              ? 'خطأ في تحميل الملف الشخصي'
              : 'Error loading profile',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onImageUploadRequested(
    ProfileImageUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploading: true, clearMessage: true));

    try {
      await _repository.uploadImage(type: event.type, file: event.file);
      final result = await _repository.getProfile(userId: userId);

      emit(
        state.copyWith(
          user: result.user,
          posts: result.posts,
          isUploading: false,
          message: event.isArabic
              ? 'تم تحديث الصورة بنجاح'
              : 'Image updated successfully',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isUploading: false,
          message: error.message,
          isSuccess: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isUploading: false,
          message: event.isArabic
              ? 'فشل في تحديث الصورة'
              : 'Failed to update image',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onImageDeleteRequested(
    ProfileImageDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploading: true, clearMessage: true));

    try {
      await _repository.deleteImage(event.type);
      final result = await _repository.getProfile(userId: userId);

      emit(
        state.copyWith(
          user: result.user,
          posts: result.posts,
          isUploading: false,
          message: event.isArabic
              ? 'تم حذف الصورة بنجاح'
              : 'Image deleted successfully',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isUploading: false,
          message: error.message,
          isSuccess: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isUploading: false,
          message: event.isArabic
              ? 'فشل في حذف الصورة'
              : 'Failed to delete image',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onFriendRequestSent(
    ProfileFriendRequestSent event,
    Emitter<ProfileState> emit,
  ) async {
    if (userId == null) return;

    try {
      await _repository.sendFriendRequest(userId!);
      emit(
        state.copyWith(
          friendshipStatus: 'request_sent',
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
              ? 'فشل إرسال طلب الصداقة'
              : 'Failed to send friend request',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onFriendRequestAccepted(
    ProfileFriendRequestAccepted event,
    Emitter<ProfileState> emit,
  ) async {
    if (userId == null) return;

    try {
      await _repository.acceptFriendRequest(userId!);
      final result = await _repository.getProfile(userId: userId);

      emit(
        state.copyWith(
          user: result.user,
          posts: result.posts,
          friendshipStatus: 'friends',
          message: event.isArabic
              ? 'تم قبول طلب الصداقة'
              : 'Friend request accepted',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (_) {
      emit(
        state.copyWith(
          message: event.isArabic
              ? 'فشل قبول طلب الصداقة'
              : 'Failed to accept friend request',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onPostDeleteRequested(
    ProfilePostDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _repository.deletePost(event.postId);
      emit(
        state.copyWith(
          posts: state.posts
              .where((post) => post['id'] != event.postId)
              .toList(),
          message: event.isArabic
              ? 'تم حذف المنشور'
              : 'Post deleted successfully',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (_) {
      emit(
        state.copyWith(
          message: event.isArabic ? 'فشل حذف المنشور' : 'Failed to delete post',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(
    ProfileMessageCleared event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
