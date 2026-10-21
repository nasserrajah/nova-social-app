import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final Map<String, dynamic> user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthRememberMeLoaded extends AuthState {
  const AuthRememberMeLoaded({this.email, this.password});

  final String? email;
  final String? password;

  bool get hasCredentials => email != null && password != null;

  @override
  List<Object?> get props => [email, password];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Emitted after the OAuth browser sheet was opened successfully.
class AuthSocialLoginLaunched extends AuthState {
  const AuthSocialLoginLaunched(this.provider);

  final String provider;

  @override
  List<Object?> get props => [provider];
}
