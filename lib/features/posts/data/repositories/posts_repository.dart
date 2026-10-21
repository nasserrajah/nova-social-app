import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/post.dart';

class ReactionResult {
  const ReactionResult({
    required this.liked,
    required this.likesCount,
    required this.message,
  });

  final bool liked;
  final int likesCount;
  final String message;
}

/// Data layer for posts, reactions and post creation/deletion.
class PostsRepository {
  PostsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String?> getToken() => _apiClient.getToken();

  Future<int?> getCurrentUserId() async {
    final token = await _apiClient.getToken();
    if (token == null) return null;

    final response = await _apiClient.get(ApiConstants.mePath, token: token);
    final data = jsonDecode(response.body);
    return _asInt(data['user']?['id']);
  }

  Future<List<Post>> getPosts() async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(ApiConstants.postsPath, token: token);
    final data = jsonDecode(response.body);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((json) => Post.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Post> getPostDetails(int postId) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      '${ApiConstants.postsPath}/$postId',
      token: token,
    );
    final data = jsonDecode(response.body);
    final postJson = data['post'] ?? data;
    return Post.fromJson(Map<String, dynamic>.from(postJson as Map));
  }

  Future<ReactionResult> toggleReaction({
    required int postId,
    required String reaction,
  }) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.post(
      '${ApiConstants.postsPath}/$postId/like',
      {'reaction': reaction},
      token: token,
    );

    final data = jsonDecode(response.body);
    return ReactionResult(
      liked: data['liked'] == true,
      likesCount: _asInt(data['likes_count']),
      message: data['message']?.toString() ?? '',
    );
  }

  Future<void> createPost({required String content, File? image}) async {
    final token = await _apiClient.getToken();
    if (token == null) {
      throw ApiException('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
    }

    if (image != null) {
      await _apiClient.uploadFile(ApiConstants.postsPath, image, {
        'content': content,
      }, token);
    } else {
      await _apiClient.post(ApiConstants.postsPath, {
        'content': content,
      }, token: token);
    }
  }

  Future<void> deletePost(int postId) async {
    final token = await _apiClient.getToken();
    await _apiClient.delete('${ApiConstants.postsPath}/$postId', token: token);
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
