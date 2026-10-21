import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/app_notification.dart';

/// Data layer for notifications.
///
/// The backend is the source of truth for the notifications themselves, while
/// the "read" flag is persisted locally so it survives app restarts and can be
/// synchronised with the server later.
class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  bool _syncedReadIds = false;

  Future<Set<int>> getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(ApiConstants.readNotificationsKey);
    if (stored == null) return <int>{};

    return stored.map(int.tryParse).whereType<int>().toSet();
  }

  Future<List<AppNotification>> getNotifications() async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      ApiConstants.notificationsPath,
      token: token,
    );

    final decoded = jsonDecode(response.body);
    final payload = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : const <String, dynamic>{};
    final list = payload['data'] as List? ?? const [];

    final readIds = await getReadIds();

    return list.whereType<Map>().map((json) {
      final notification = AppNotification.fromJson(
        Map<String, dynamic>.from(json),
      );
      return readIds.contains(notification.id)
          ? notification.copyWith(read: true)
          : notification;
    }).toList();
  }

  Future<void> saveReadId(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getStringList(ApiConstants.readNotificationsKey) ?? <String>[];
    final id = notificationId.toString();

    if (!stored.contains(id)) {
      stored.add(id);
      await prefs.setStringList(ApiConstants.readNotificationsKey, stored);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    await saveReadId(notificationId);

    final token = await _apiClient.getToken();
    try {
      await _apiClient.put(
        '${ApiConstants.notificationsPath}/$notificationId/read',
        const {},
        token: token,
      );
    } catch (_) {
      // The local flag is enough; the next sync will retry the server call.
    }
  }

  Future<void> markAllAsRead(List<int> notificationIds) async {
    for (final id in notificationIds) {
      await saveReadId(id);
    }

    final token = await _apiClient.getToken();
    await _apiClient.post(
      '${ApiConstants.notificationsPath}/mark-all-read',
      const {},
      token: token,
    );
  }

  Future<void> clearReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.readNotificationsKey);
  }

  /// Pushes the locally stored read ids to the server.
  ///
  /// Failures are ignored on purpose: this is a best-effort background sync.
  Future<void> syncReadNotifications() async {
    if (_syncedReadIds) return;

    final readIds = await getReadIds();
    if (readIds.isEmpty) {
      _syncedReadIds = true;
      return;
    }

    final token = await _apiClient.getToken();

    for (final id in readIds) {
      try {
        await _apiClient.put(
          '${ApiConstants.notificationsPath}/$id/read',
          const {},
          token: token,
        );
      } catch (_) {
        // Keep the local value and retry on the next launch.
      }
    }

    _syncedReadIds = true;
  }

  Future<void> acceptFriendRequest(int userId) async {
    final token = await _apiClient.getToken();
    await _apiClient.post(
      '${ApiConstants.friendsPath}/accept/$userId',
      const {},
      token: token,
    );
  }

  Future<void> rejectFriendRequest(int userId) async {
    final token = await _apiClient.getToken();
    await _apiClient.post(
      '${ApiConstants.friendsPath}/reject/$userId',
      const {},
      token: token,
    );
  }
}
