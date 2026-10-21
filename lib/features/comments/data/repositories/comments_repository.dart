import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/comment.dart';

class CommentsRepository {
  CommentsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Comment>> getComments(int postId) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      '${ApiConstants.postsPath}/$postId/comments',
      token: token,
    );

    final data = jsonDecode(response.body);
    final list = data['data'] as List? ?? const [];

    return list
        .whereType<Map>()
        .map((json) => Comment.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Comment> addComment({
    required int postId,
    required String content,
  }) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.post(
      '${ApiConstants.postsPath}/$postId/comments',
      {'content': content},
      token: token,
    );

    final data = jsonDecode(response.body);
    return Comment.fromJson(Map<String, dynamic>.from(data['comment'] as Map));
  }

  Future<void> deleteComment(int commentId) async {
    final token = await _apiClient.getToken();
    await _apiClient.delete('/api/comments/$commentId', token: token);
  }
}
