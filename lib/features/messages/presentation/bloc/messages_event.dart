import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class MessagesLoadRequested extends MessagesEvent {
  const MessagesLoadRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class MessagesRefreshRequested extends MessagesEvent {
  const MessagesRefreshRequested({this.isArabic = false});

  final bool isArabic;

  @override
  List<Object?> get props => [isArabic];
}

class MessagesMessageCleared extends MessagesEvent {
  const MessagesMessageCleared();
}
