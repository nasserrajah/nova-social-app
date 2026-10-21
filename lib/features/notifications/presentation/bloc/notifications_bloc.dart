import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required NotificationsRepository repository})
    : _repository = repository,
      super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllReadRequested);
    on<NotificationsClearReadRequested>(_onClearReadRequested);
    on<FriendRequestAccepted>(_onFriendRequestAccepted);
    on<FriendRequestRejected>(_onFriendRequestRejected);
    on<NotificationsMessageCleared>(_onMessageCleared);
  }

  final NotificationsRepository _repository;

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));

    try {
      await _repository.syncReadNotifications();
      final notifications = await _repository.getNotifications();
      emit(state.copyWith(notifications: notifications, isLoading: false));
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
              ? 'فشل تحميل الإشعارات'
              : 'Failed to load notifications',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final updated = state.notifications.map((notification) {
      return notification.id == event.notificationId
          ? notification.copyWith(read: true)
          : notification;
    }).toList();

    emit(state.copyWith(notifications: updated));

    try {
      await _repository.markAsRead(event.notificationId);
    } catch (_) {
      // The notification is already marked locally.
    }
  }

  Future<void> _onMarkAllReadRequested(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final ids = state.notifications
        .where((notification) => !notification.read)
        .map((notification) => notification.id)
        .toList();

    try {
      if (ids.isNotEmpty) {
        await _repository.markAllAsRead(ids);
      }

      emit(
        state.copyWith(
          notifications: state.notifications
              .map((notification) => notification.copyWith(read: true))
              .toList(),
          message: event.isArabic
              ? 'تم تحديد جميع الإشعارات كمقروءة'
              : 'All notifications marked as read',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (_) {
      emit(
        state.copyWith(
          message: event.isArabic
              ? 'فشل تحديد الإشعارات كمقروءة'
              : 'Failed to mark notifications as read',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onClearReadRequested(
    NotificationsClearReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.clearReadNotifications();
      final notifications = await _repository.getNotifications();
      emit(
        state.copyWith(
          notifications: notifications,
          message: event.isArabic
              ? 'تم مسح جميع الإشعارات المقروءة'
              : 'All read notifications cleared',
          isSuccess: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          message: event.isArabic
              ? 'فشل مسح الإشعارات المقروءة'
              : 'Failed to clear read notifications',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onFriendRequestAccepted(
    FriendRequestAccepted event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.acceptFriendRequest(event.userId);
      final notifications = await _repository.getNotifications();
      emit(
        state.copyWith(
          notifications: notifications,
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

  Future<void> _onFriendRequestRejected(
    FriendRequestRejected event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.rejectFriendRequest(event.userId);
      final notifications = await _repository.getNotifications();
      emit(
        state.copyWith(
          notifications: notifications,
          message: event.isArabic
              ? 'تم رفض طلب الصداقة'
              : 'Friend request rejected',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(message: error.message, isSuccess: false));
    } catch (_) {
      emit(
        state.copyWith(
          message: event.isArabic
              ? 'فشل رفض طلب الصداقة'
              : 'Failed to reject friend request',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(
    NotificationsMessageCleared event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
