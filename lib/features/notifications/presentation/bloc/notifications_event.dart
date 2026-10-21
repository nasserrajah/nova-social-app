import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class NotificationMarkedAsRead extends NotificationsEvent {
  const NotificationMarkedAsRead(this.notificationId);

  final int notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class NotificationsMarkAllReadRequested extends NotificationsEvent {
  const NotificationsMarkAllReadRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class NotificationsClearReadRequested extends NotificationsEvent {
  const NotificationsClearReadRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class FriendRequestAccepted extends NotificationsEvent {
  const FriendRequestAccepted(this.userId, {this.isArabic = false});

  final int userId;
  final bool isArabic;

  @override
  List<Object?> get props => [userId, isArabic];
}

class FriendRequestRejected extends NotificationsEvent {
  const FriendRequestRejected(this.userId, {this.isArabic = false});

  final int userId;
  final bool isArabic;

  @override
  List<Object?> get props => [userId, isArabic];
}

class NotificationsMessageCleared extends NotificationsEvent {
  const NotificationsMessageCleared();
}
