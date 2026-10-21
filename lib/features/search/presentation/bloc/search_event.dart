import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchSubmitted extends SearchEvent {
  const SearchSubmitted({
    required this.query,
    required this.searchUsers,
    this.isArabic = false,
  });

  final String query;
  final bool searchUsers;
  final bool isArabic;

  @override
  List<Object?> get props => [query, searchUsers, isArabic];
}

class SearchTabChanged extends SearchEvent {
  const SearchTabChanged({
    required this.index,
    required this.query,
    this.isArabic = false,
  });

  final int index;
  final String query;
  final bool isArabic;

  @override
  List<Object?> get props => [index, query, isArabic];
}

class SearchFriendRequestSent extends SearchEvent {
  const SearchFriendRequestSent({required this.userId, this.isArabic = false});

  final int userId;
  final bool isArabic;

  @override
  List<Object?> get props => [userId, isArabic];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

class SearchMessageCleared extends SearchEvent {
  const SearchMessageCleared();
}
