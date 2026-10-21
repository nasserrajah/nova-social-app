import 'package:equatable/equatable.dart';

import '../../data/models/app_notification.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
  });

  final List<AppNotification> notifications;
  final bool isLoading;
  final String? message;
  final bool isSuccess;

  int get unreadCount =>
      notifications.where((notification) => !notification.read).length;

  int get readCount => notifications.length - unreadCount;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, message, isSuccess];
}
