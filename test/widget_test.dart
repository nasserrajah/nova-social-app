import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/models/user.dart';
import 'package:social_app/core/utils/date_formatter.dart';

void main() {
  group('User.fromJson', () {
    test('reads the profile image and numeric fields', () {
      final user = User.fromJson({
        'id': 7,
        'name': 'Nova User',
        'email': 'nova@example.com',
        'profile_image': 'avatars/7.png',
        'friends_count': '3',
      });

      expect(user.id, 7);
      expect(user.name, 'Nova User');
      expect(user.email, 'nova@example.com');
      expect(user.profileImage, 'avatars/7.png');
      expect(user.avatar, 'avatars/7.png');
      expect(user.friendsCount, 3);
    });
  });

  group('DateFormatter', () {
    test('formats a fresh date as "now" in both languages', () {
      final now = DateTime.now();

      expect(DateFormatter.relative(now, isArabic: true), 'الآن');
      expect(DateFormatter.relative(now, isArabic: false), 'Now');
    });

    test('formats a full date using the selected locale order', () {
      final date = DateTime(2026, 3, 9, 14, 5);

      expect(
        DateFormatter.fullDate(date, isArabic: true),
        '09/03/2026 - 14:05',
      );
      expect(
        DateFormatter.fullDate(date, isArabic: false),
        '03/09/2026 - 14:05',
      );
    });
  });
}
