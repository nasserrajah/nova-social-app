import 'package:equatable/equatable.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

class PostDetailRequested extends PostDetailEvent {
  const PostDetailRequested(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostDetailMessageCleared extends PostDetailEvent {
  const PostDetailMessageCleared();
}
