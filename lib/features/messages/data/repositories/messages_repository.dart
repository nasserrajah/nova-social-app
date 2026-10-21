import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_message.dart';

class MessagesRepository {
  MessagesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<int?> getCurrentUserId() async {
    final token = await _apiClient.getToken();
    if (token == null) return null;

    final response = await _apiClient.get(ApiConstants.mePath, token: token);
    final data = jsonDecode(response.body);
    final id = data['user']?['id'];

    if (id is int) return id;
    if (id is num) return id.toInt();
    return int.tryParse(id?.toString() ?? '');
  }

  Future<List<Conversation>> getConversations(int? currentUserId) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      ApiConstants.conversationsPath,
      token: token,
    );
    final data = jsonDecode(response.body);

    return (data['data'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (json) => Conversation.fromJson(
            Map<String, dynamic>.from(json),
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }

  Future<List<User>> getFriends() async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      ApiConstants.friendsPath,
      token: token,
    );
    final data = jsonDecode(response.body);

    return (data['data'] as List? ?? const [])
        .whereType<Map>()
        .map((json) => User.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<List<ChatMessage>> getMessages({
    required int friendId,
    required int? currentUserId,
  }) async {
    final token = await _apiClient.getToken();
    final response = await _apiClient.get(
      '/api/messages/$friendId',
      token: token,
    );
    final data = jsonDecode(response.body);

    return (data['data'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (json) => ChatMessage.fromJson(
            Map<String, dynamic>.from(json),
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }

  Future<void> sendMessage({
    required int friendId,
    required String message,
  }) async {
    final token = await _apiClient.getToken();
    await _apiClient.post('/api/messages/$friendId', {
      'message': message,
    }, token: token);
  }
}
