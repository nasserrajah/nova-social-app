/// Central place for every backend-related constant.
///
/// Change [baseUrl] only here if the API host changes.
class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://social-api-30ta.onrender.com';
  static const String storageUrl = '$baseUrl/storage';

  // Secure storage keys.
  static const String tokenKey = 'token';

  // Shared preferences keys.
  static const String isLoggedInKey = 'is_logged_in';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String savedPasswordKey = 'saved_password';
  static const String readNotificationsKey = 'user_read_notifications';

  // Auth endpoints.
  static const String loginPath = '/api/login';
  static const String registerPath = '/api/register';
  static const String logoutPath = '/api/logout';
  static const String forgotPasswordPath = '/api/password/email';
  static const String mePath = '/api/me';

  // Post endpoints.
  static const String postsPath = '/api/posts';
  static const String likesPath = '/api/likes';
  static const String notificationsPath = '/api/notifications';
  static const String profilePath = '/api/profile';
  static const String friendsPath = '/api/friends';
  static const String conversationsPath = '/api/conversations';
  static const String searchPath = '/api/search';
}
