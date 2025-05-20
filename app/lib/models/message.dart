// models/message.dart
class Message {
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
