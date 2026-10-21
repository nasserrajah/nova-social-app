import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

/// Result returned by a successful login/registration call.
class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;
}

/// Data layer for everything related to authentication.
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required FlutterSecureStorage storage,
  }) : _apiClient = apiClient,
       _storage = storage;

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  Future<AuthResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _apiClient.post(ApiConstants.loginPath, {
      'email': email,
      'password': password,
    });

    final data = _decode(response.body);
    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException('لم يتم استلام التوكن من السيرفر');
    }

    await _storage.write(key: ApiConstants.tokenKey, value: token);
    await _setLoggedIn(true);
    await saveRememberMe(
      remember: rememberMe,
      email: email,
      password: password,
    );

    return AuthResult(
      token: token,
      user: Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 8),
  }) async {
    Object? lastError;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _registerOnce(
          name: name,
          email: email,
          password: password,
        );
      } catch (error) {
        lastError = error;
        if (attempt == maxRetries - 1) rethrow;
        await Future<void>.delayed(retryDelay);
      }
    }

    throw ApiException(lastError?.toString() ?? 'فشل التسجيل');
  }

  Future<AuthResult> _registerOnce({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(ApiConstants.registerPath, {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });

    final data = _decode(response.body);
    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException('لم يتم استلام التوكن من السيرفر');
    }

    await _storage.write(key: ApiConstants.tokenKey, value: token);
    await _setLoggedIn(true);

    return AuthResult(
      token: token,
      user: Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }

  /// Persists a token obtained from an OAuth callback.
  Future<void> loginWithToken({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
    await _setLoggedIn(true);
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(ApiConstants.forgotPasswordPath, {'email': email});
  }

  Future<void> logout() async {
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.post(ApiConstants.logoutPath, {}, token: token);
      } catch (_) {
        // Local logout must succeed even if the server is unreachable.
      }
      await _storage.delete(key: ApiConstants.tokenKey);
    }

    await _setLoggedIn(false);
  }

  Future<Map<String, String?>> getRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(ApiConstants.rememberMeKey) ?? false;

    if (!remember) return const {};

    return {
      'email': prefs.getString(ApiConstants.savedEmailKey),
      'password': prefs.getString(ApiConstants.savedPasswordKey),
    };
  }

  Future<void> saveRememberMe({
    required bool remember,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (remember) {
      await prefs.setBool(ApiConstants.rememberMeKey, true);
      await prefs.setString(ApiConstants.savedEmailKey, email);
      await prefs.setString(ApiConstants.savedPasswordKey, password);
    } else {
      await prefs.setBool(ApiConstants.rememberMeKey, false);
      await prefs.remove(ApiConstants.savedEmailKey);
      await prefs.remove(ApiConstants.savedPasswordKey);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final flag = prefs.getBool(ApiConstants.isLoggedInKey) ?? false;
    final token = await getToken();
    return flag && token != null && token.isNotEmpty;
  }

  Future<String?> getToken() => _storage.read(key: ApiConstants.tokenKey);

  Future<void> _setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ApiConstants.isLoggedInKey, value);
  }

  Map<String, dynamic> _decode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }
}
