import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl;

  ChatService(this.baseUrl);

  // Gửi tin nhắn giữa 2 người dùng
  Future<bool> sendMessage(int senderId, int receiverId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      }),
    );

    return response.statusCode == 200;
  }

  // Lấy tất cả các cuộc trò chuyện của người dùng với tin nhắn mới nhất
  Future<List<Map<String, dynamic>>> getConversations(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/history/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  // Lấy lịch sử tin nhắn giữa 2 người dùng
  Future<List<Map<String, dynamic>>> getChatHistory(
    int userId,
    int otherUserId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/history/$userId/$otherUserId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }
}
