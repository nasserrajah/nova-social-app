import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Handles the OAuth browser flow and the callback exchange.
class SocialAuthService {
  SocialAuthService({required this.baseUrl});

  final String baseUrl;

  Future<void> signIn(String provider) async {
    final url = switch (provider) {
      'google' => _googleUrl(),
      'facebook' => _facebookUrl(),
      'twitter' => _twitterUrl(),
      _ => throw Exception('مزود غير معروف'),
    };

    await _launch(url);
  }

  Future<Map<String, dynamic>> handleCallback(
    String provider,
    String code,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/$provider/callback'),
      body: {'code': code, 'provider': provider},
    );

    if (response.statusCode != 200) {
      throw Exception('فشل تسجيل الدخول عبر $provider');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> handleDeepLink(Uri uri) async {
    final provider = uri.host;
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      throw Exception('Authentication error: $error');
    }
    if (code == null) {
      throw Exception('No authorization code received');
    }

    return handleCallback(provider, code);
  }

  String _googleUrl() {
    const clientId =
        '249816355188-1pnj1gfaa5lgu4bs4iqucht9ebcajtam.apps.googleusercontent.com';
    const redirectUri = 'socialapp://google';

    return 'https://accounts.google.com/o/oauth2/v2/auth?'
        'response_type=code&'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=email%20profile&'
        'state=google_auth';
  }

  String _facebookUrl() {
    const clientId = 'your_facebook_client_id';
    const redirectUri = 'socialapp://facebook';

    return 'https://www.facebook.com/v12.0/dialog/oauth?'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=email,public_profile&'
        'state=facebook_auth';
  }

  String _twitterUrl() {
    const clientId = 'your_twitter_client_id';
    const redirectUri = 'socialapp://twitter';

    return 'https://twitter.com/i/oauth2/authorize?'
        'response_type=code&'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=tweet.read%20users.read%20offline.access&'
        'state=twitter_auth&'
        'code_challenge=challenge&'
        'code_challenge_method=plain';
  }

  Future<void> _launch(String authUrl) async {
    final uri = Uri.parse(authUrl);
    if (!await canLaunchUrl(uri)) {
      throw Exception('Could not launch authentication URL');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
