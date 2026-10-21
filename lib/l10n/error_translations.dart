// utils/error_translations.dart
class ErrorTranslations {
  static Map<String, Map<String, String>> errorMessages = {
    'The email has already been taken': {
      'ar': 'البريد الإلكتروني مستخدم بالفعل',
      'en': 'The email has already been taken',
    },
    'Invalid email or password': {
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'en': 'Invalid email or password',
    },
    'Network error': {'ar': 'خطأ في الاتصال بالشبكة', 'en': 'Network error'},
    'User not found': {'ar': 'المستخدم غير موجود', 'en': 'User not found'},
    'Unauthorized': {'ar': 'غير مصرح بالدخول', 'en': 'Unauthorized'},
    'Server error': {'ar': 'خطأ في الخادم', 'en': 'Server error'},
    'Connection timeout': {
      'ar': 'انتهت مهلة الاتصال',
      'en': 'Connection timeout',
    },
    'No internet connection': {
      'ar': 'لا يوجد اتصال بالإنترنت',
      'en': 'No internet connection',
    },
    'Password is too short': {
      'ar': 'كلمة المرور قصيرة جداً',
      'en': 'Password is too short',
    },
    'Invalid email format': {
      'ar': 'صيغة البريد الإلكتروني غير صحيحة',
      'en': 'Invalid email format',
    },
    'Name is required': {'ar': 'الاسم مطلوب', 'en': 'Name is required'},
    'Email is required': {
      'ar': 'البريد الإلكتروني مطلوب',
      'en': 'Email is required',
    },
    'Password is required': {
      'ar': 'كلمة المرور مطلوبة',
      'en': 'Password is required',
    },
  };

  static String translate(String error, String languageCode) {
    // البحث عن تطابق كامل
    if (errorMessages.containsKey(error)) {
      return errorMessages[error]![languageCode] ?? error;
    }

    // البحث عن تطابق جزئي
    for (var key in errorMessages.keys) {
      if (error.toLowerCase().contains(key.toLowerCase())) {
        return errorMessages[key]![languageCode] ?? error;
      }
    }

    // إذا لم توجد ترجمة، ارجع الرسالة الأصلية
    return error;
  }
}
