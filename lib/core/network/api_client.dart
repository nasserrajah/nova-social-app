import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../l10n/error_translations.dart';
import '../constants/api_constants.dart';

/// Thrown by [ApiClient] whenever a request fails.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin HTTP wrapper around the Nova REST API.
///
/// The client is responsible for:
/// * attaching the bearer token,
/// * parsing backend error messages,
/// * translating errors to the current app language,
/// * turning network failures into readable [ApiException]s.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.storage,
    http.Client? httpClient,
    this.currentLanguage = 'en',
  }) : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;
  final FlutterSecureStorage storage;

  String currentLanguage;

  void setLanguage(String languageCode) {
    currentLanguage = languageCode;
  }

  String translateError(String error) {
    return ErrorTranslations.translate(error, currentLanguage);
  }

  Future<String?> getToken() => storage.read(key: ApiConstants.tokenKey);

  // ---------------------------------------------------------------------------
  // HTTP verbs
  // ---------------------------------------------------------------------------

  /// Sends a multipart/form-data POST request.
  ///
  /// The backend expects form data for every write endpoint, so this method is
  /// intentionally implemented with [http.MultipartRequest].
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers(token));

    body.forEach((key, value) {
      request.fields[key] = value?.toString() ?? '';
    });

    _log('API POST $uri');
    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _log('API ${response.statusCode} $uri');
      _ensureSuccess(response, uri);
      return response;
    } on SocketException {
      throw ApiException(translateError('No internet connection'));
    } on http.ClientException {
      throw ApiException(translateError('Network error'));
    } on FormatException {
      throw ApiException(translateError('Invalid response format'));
    }
  }

  Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    _log('API GET $uri');
    try {
      final response = await httpClient.get(uri, headers: _headers(token));
      _log('API ${response.statusCode} $uri');
      _ensureSuccess(response, uri);
      return response;
    } on SocketException {
      throw ApiException(translateError('No internet connection'));
    } on http.ClientException {
      throw ApiException(translateError('Network error'));
    } on FormatException {
      throw ApiException(translateError('Invalid response format'));
    }
  }

  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    _log('API PUT $uri');
    try {
      final response = await httpClient.put(
        uri,
        headers: _headers(token, json: true),
        body: jsonEncode(body),
      );
      _log('API ${response.statusCode} $uri');
      _ensureSuccess(response, uri);
      return response;
    } on SocketException {
      throw ApiException(translateError('No internet connection'));
    } on http.ClientException {
      throw ApiException(translateError('Network error'));
    } on FormatException {
      throw ApiException(translateError('Invalid response format'));
    }
  }

  Future<http.Response> delete(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    _log('API DELETE $uri');
    try {
      final response = await httpClient.delete(uri, headers: _headers(token));
      _log('API ${response.statusCode} $uri');
      _ensureSuccess(response, uri);
      return response;
    } on SocketException {
      throw ApiException(translateError('No internet connection'));
    } on http.ClientException {
      throw ApiException(translateError('Network error'));
    } on FormatException {
      throw ApiException(translateError('Invalid response format'));
    }
  }

  /// Uploads a single image with additional form fields.
  Future<http.Response> uploadFile(
    String path,
    File file,
    Map<String, String> fields,
    String token, {
    String fieldName = 'image',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers(token))
      ..fields.addAll(fields)
      ..files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    _log('API UPLOAD $uri');
    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _log('API ${response.statusCode} $uri');
      _ensureSuccess(response, uri);
      return response;
    } on SocketException {
      throw ApiException(translateError('No internet connection'));
    } on http.ClientException {
      throw ApiException(translateError('Network error'));
    } on FormatException {
      throw ApiException(translateError('Invalid response format'));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, String> _headers(String? token, {bool json = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _ensureSuccess(http.Response response, Uri uri) {
    if (response.statusCode < 400) return;

    final message = _extractErrorMessage(response.body);
    throw ApiException(
      translateError(message),
      statusCode: response.statusCode,
    );
  }

  String _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body);

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        if (data['detail'] != null) return data['detail'].toString();

        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    } catch (_) {
      // The body is not JSON; fall through to the generic message.
    }
    return 'Unknown error occurred';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
