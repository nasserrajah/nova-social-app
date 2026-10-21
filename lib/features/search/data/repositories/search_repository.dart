import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/api_client.dart';
import '../../../posts/data/models/post.dart';

class SearchRepository {
  SearchRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Post>> searchPosts(String query) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      '${ApiConstants.searchPath}?q=${Uri.encodeQueryComponent(query)}',
      token: token,
    );
    final data = jsonDecode(response.body);

    return (data['posts'] as List? ?? const [])
        .whereType<Map>()
        .map((json) => Post.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<List<User>> searchUsers(String query) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      '${ApiConstants.searchPath}/users?q=${Uri.encodeQueryComponent(query)}',
      token: token,
    );
    final data = jsonDecode(response.body);

    return (data['data'] as List? ?? const [])
        .whereType<Map>()
        .map((json) => User.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Map<int, String>> getFriendshipStatuses(List<User> users) async {
    final token = await _apiClient.getToken();
    final statuses = <int, String>{};

    await Future.wait(
      users.map((user) async {
        try {
          final response = await _apiClient.get(
            '${ApiConstants.friendsPath}/status/${user.id}',
            token: token,
          );
          final data = jsonDecode(response.body);
          statuses[user.id] = data['status']?.toString() ?? 'not_friends';
        } catch (_) {
          statuses[user.id] = 'not_friends';
        }
      }),
    );

    return statuses;
  }

  Future<void> sendFriendRequest(int userId) async {
    final token = await _apiClient.getToken();
    await _apiClient.post(
      '${ApiConstants.friendsPath}/request/$userId',
      const {},
      token: token,
    );
  }
}
