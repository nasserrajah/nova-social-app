import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

class CreatePostSubmitted extends CreatePostEvent {
  const CreatePostSubmitted({
    required this.content,
    this.image,
    this.isArabic = false,
  });

  final String content;
  final File? image;
  final bool isArabic;

  @override
  List<Object?> get props => [content, image?.path, isArabic];
}

class CreatePostMessageCleared extends CreatePostEvent {
  const CreatePostMessageCleared();
}
