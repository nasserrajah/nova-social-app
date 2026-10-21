import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/social_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    required SocialAuthService socialAuthService,
  }) : _repository = repository,
       _socialAuthService = socialAuthService,
       super(const AuthInitial()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<SocialAuthCallbackReceived>(_onSocialAuthCallbackReceived);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RememberMeRequested>(_onRememberMeRequested);
    on<AuthMessageCleared>(_onMessageCleared);
  }

  final AuthRepository _repository;
  final SocialAuthService _socialAuthService;

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      emit(
        isLoggedIn ? const AuthAuthenticated({}) : const AuthUnauthenticated(),
      );
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _repository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      emit(AuthAuthenticated(result.user));
    } on ApiException catch (error) {
      emit(AuthFailure(error.message));
    } catch (error) {
      emit(
        AuthFailure(
          event.isArabic
              ? 'خطأ في الشبكة أو السيرفر: $error'
              : 'Network or server error: $error',
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(result.user));
    } on ApiException catch (error) {
      emit(AuthFailure(error.message));
    } catch (error) {
      emit(
        AuthFailure(
          event.isArabic
              ? 'خطأ في الشبكة أو السيرفر: $error'
              : 'Network or server error: $error',
        ),
      );
    }
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _socialAuthService.signIn(event.provider);
      emit(AuthSocialLoginLaunched(event.provider));
    } catch (error) {
      emit(
        AuthFailure(
          event.isArabic
              ? 'فشل تسجيل الدخول عبر ${event.provider}: $error'
              : 'Failed to sign in with ${event.provider}: $error',
        ),
      );
    }
  }

  Future<void> _onSocialAuthCallbackReceived(
    SocialAuthCallbackReceived event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _socialAuthService.handleCallback(
        event.provider,
        event.code,
      );

      final token = result['token']?.toString();
      if (token == null || token.isEmpty) {
        emit(
          AuthFailure(
            event.isArabic
                ? 'لم يتم استلام التوكن من السيرفر'
                : 'No token was received from the server',
          ),
        );
        return;
      }

      // The token is persisted by the repository after a social login.
      await _repository.loginWithToken(
        token: token,
        user: Map<String, dynamic>.from(
          result['user'] as Map? ?? const <String, dynamic>{},
        ),
      );

      emit(
        AuthAuthenticated(
          Map<String, dynamic>.from(
            result['user'] as Map? ?? const <String, dynamic>{},
          ),
        ),
      );
    } on ApiException catch (error) {
      emit(AuthFailure(error.message));
    } catch (error) {
      emit(
        AuthFailure(
          event.isArabic
              ? 'فشل معالجة تسجيل الدخول عبر ${event.provider}: $error'
              : 'Failed to complete ${event.provider} sign-in: $error',
        ),
      );
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _repository.forgotPassword(event.email);
      emit(const AuthPasswordResetSent());
    } on ApiException catch (error) {
      emit(AuthFailure(error.message));
    } catch (error) {
      emit(
        AuthFailure(
          event.isArabic
              ? 'خطأ في إرسال رابط استعادة كلمة المرور: $error'
              : 'Failed to send the password reset link: $error',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onRememberMeRequested(
    RememberMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    final data = await _repository.getRememberMeData();
    emit(
      AuthRememberMeLoaded(email: data['email'], password: data['password']),
    );
  }

  void _onMessageCleared(AuthMessageCleared event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }
}
