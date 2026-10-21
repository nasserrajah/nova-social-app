/// Date/time helpers shared by posts, comments, notifications and chats.
class DateFormatter {
  const DateFormatter._();

  static String relative(DateTime date, {required bool isArabic}) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return isArabic ? 'الآن' : 'Now';
    if (difference.inMinutes < 60) {
      return isArabic
          ? 'منذ ${difference.inMinutes} دقيقة'
          : '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return isArabic
          ? 'منذ ${difference.inHours} ساعة'
          : '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return isArabic
          ? 'منذ ${difference.inDays} يوم'
          : '${difference.inDays}d ago';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return isArabic ? '$day/$month/$year' : '$month/$day/$year';
  }

  static String fullDate(DateTime date, {required bool isArabic}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return isArabic
        ? '$day/$month/$year - $hour:$minute'
        : '$month/$day/$year - $hour:$minute';
  }

  static String messageTime(DateTime time, {required bool isArabic}) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) return isArabic ? 'الآن' : 'Now';
    if (difference.inHours < 1) {
      return isArabic
          ? '${difference.inMinutes} د'
          : '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month} '
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String conversationTime(DateTime time, {required bool isArabic}) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) return isArabic ? 'الآن' : 'Now';
    if (difference.inHours < 1) {
      return isArabic
          ? '${difference.inMinutes} د'
          : '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays < 7) {
      return isArabic ? '${difference.inDays} يوم' : '${difference.inDays}d';
    }
    return '${time.day}/${time.month}';
  }
}
