import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/like.dart';

class LikesRepository {
  LikesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Like>> getLikes() async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(ApiConstants.likesPath, token: token);

    final data = jsonDecode(response.body);
    final list = data['data'] as List? ?? const [];

    return list
        .whereType<Map>()
        .map((json) => Like.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> removeLike(int likeId) async {
    final token = await _apiClient.getToken();
    await _apiClient.delete('${ApiConstants.likesPath}/$likeId', token: token);
  }
}
