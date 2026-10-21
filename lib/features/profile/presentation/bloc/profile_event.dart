import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class ProfileImageUploadRequested extends ProfileEvent {
  const ProfileImageUploadRequested({
    required this.type,
    required this.file,
    this.isArabic = false,
  });

  final String type;
  final File file;
  final bool isArabic;

  @override
  List<Object?> get props => [type, file.path, isArabic];
}

class ProfileImageDeleteRequested extends ProfileEvent {
  const ProfileImageDeleteRequested({
    required this.type,
    this.isArabic = false,
  });

  final String type;
  final bool isArabic;

  @override
  List<Object?> get props => [type, isArabic];
}

class ProfileFriendRequestSent extends ProfileEvent {
  const ProfileFriendRequestSent({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class ProfileFriendRequestAccepted extends ProfileEvent {
  const ProfileFriendRequestAccepted({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class ProfilePostDeleteRequested extends ProfileEvent {
  const ProfilePostDeleteRequested({
    required this.postId,
    this.isArabic = false,
  });

  final int postId;
  final bool isArabic;

  @override
  List<Object?> get props => [postId, isArabic];
}

class ProfileMessageCleared extends ProfileEvent {
  const ProfileMessageCleared();
}
