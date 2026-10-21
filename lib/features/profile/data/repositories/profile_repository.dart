import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class ProfileResult {
  const ProfileResult({required this.user, required this.posts});

  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> posts;
}

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ProfileResult> getProfile({int? userId}) async {
    final token = await _apiClient.getToken();
    final path = userId == null
        ? ApiConstants.profilePath
        : '${ApiConstants.profilePath}/$userId';

    final response = await _apiClient.get(path, token: token);
    final data = jsonDecode(response.body);

    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};
    final posts = (data['posts'] as List? ?? const [])
        .whereType<Map>()
        .map((post) => Map<String, dynamic>.from(post))
        .toList();

    if (user['friends_count'] == null) {
      user['friends_count'] = await getFriendsCount();
    }

    return ProfileResult(user: user, posts: posts);
  }

  Future<int> getFriendsCount() async {
    try {
      final token = await _apiClient.getToken();
      final response = await _apiClient.get(
        ApiConstants.friendsPath,
        token: token,
      );
      final data = jsonDecode(response.body);
      return (data['data'] as List? ?? const []).length;
    } catch (_) {
      return 0;
    }
  }

  Future<String> getFriendshipStatus(int userId) async {
    try {
      final token = await _apiClient.getToken();
      final response = await _apiClient.get(
        '${ApiConstants.friendsPath}/status/$userId',
        token: token,
      );
      final data = jsonDecode(response.body);
      return data['status']?.toString() ?? 'not_friends';
    } catch (_) {
      return 'not_friends';
    }
  }

  Future<void> uploadImage({required String type, required File file}) async {
    final token = await _apiClient.getToken();
    if (token == null) {
      throw ApiException('Session expired, please login again');
    }

    await _apiClient.uploadFile(
      '${ApiConstants.profilePath}/upload-image',
      file,
      {'type': type},
      token,
    );
  }

  Future<void> deleteImage(String type) async {
    final token = await _apiClient.getToken();
    await _apiClient.delete(
      '${ApiConstants.profilePath}/images/$type',
      token: token,
    );
  }

  Future<void> sendFriendRequest(int userId) async {
    final token = await _apiClient.getToken();
    await _apiClient.post(
      '${ApiConstants.friendsPath}/request/$userId',
      const {},
      token: token,
    );
  }

  Future<void> acceptFriendRequest(int userId) async {
    final token = await _apiClient.getToken();
    await _apiClient.post(
      '${ApiConstants.friendsPath}/accept/$userId',
      const {},
      token: token,
    );
  }

  Future<void> deletePost(int postId) async {
    final token = await _apiClient.getToken();
    await _apiClient.delete('${ApiConstants.postsPath}/$postId', token: token);
  }
}
