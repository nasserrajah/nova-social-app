import 'package:equatable/equatable.dart';

abstract class LikesEvent extends Equatable {
  const LikesEvent();

  /// Whether user-facing messages should be shown in Arabic.
  bool get isArabic => false;

  @override
  List<Object?> get props => [];
}

class LikesLoadRequested extends LikesEvent {
  const LikesLoadRequested({this.isArabic = false});

  @override
  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class LikeRemovalRequested extends LikesEvent {
  const LikeRemovalRequested(this.likeId, {this.isArabic = false});

  final int likeId;

  @override
  final bool isArabic;

  @override
  List<Object?> get props => [likeId, isArabic];
}

class LikesMessageCleared extends LikesEvent {
  const LikesMessageCleared();
}
