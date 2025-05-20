class ChatContact {
  final int userId;
  final String fullName;
  final String lastMessage;
  final String lastMessageTime;

  ChatContact({
    required this.userId,
    required this.fullName,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      userId: json['userId'],
      fullName: json['fullName'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
    );
  }
}
