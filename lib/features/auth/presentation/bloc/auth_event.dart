import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Asked by the splash screen to restore a previous session.
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
    required this.rememberMe,
    this.isArabic = false,
  });

  final String email;
  final String password;
  final bool rememberMe;
  final bool isArabic;

  @override
  List<Object?> get props => [email, password, rememberMe, isArabic];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.isArabic = false,
  });

  final String name;
  final String email;
  final String password;
  final bool isArabic;

  @override
  List<Object?> get props => [name, email, password, isArabic];
}

class SocialLoginRequested extends AuthEvent {
  const SocialLoginRequested(this.provider, {this.isArabic = false});

  final String provider;
  final bool isArabic;

  @override
  List<Object?> get props => [provider, isArabic];
}

class SocialAuthCallbackReceived extends AuthEvent {
  const SocialAuthCallbackReceived({
    required this.provider,
    required this.code,
    this.isArabic = false,
  });

  final String provider;
  final String code;
  final bool isArabic;

  @override
  List<Object?> get props => [provider, code, isArabic];
}

class ForgotPasswordRequested extends AuthEvent {
  const ForgotPasswordRequested(this.email, {this.isArabic = false});

  final String email;
  final bool isArabic;

  @override
  List<Object?> get props => [email, isArabic];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RememberMeRequested extends AuthEvent {
  const RememberMeRequested();
}

class AuthMessageCleared extends AuthEvent {
  const AuthMessageCleared();
}
