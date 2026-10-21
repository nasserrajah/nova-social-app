import 'package:equatable/equatable.dart';

class CreatePostState extends Equatable {
  const CreatePostState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.message,
  });

  final bool isSubmitting;
  final bool isSuccess;
  final String? message;

  CreatePostState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? message,
    bool clearMessage = false,
  }) {
    return CreatePostState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, message];
}
