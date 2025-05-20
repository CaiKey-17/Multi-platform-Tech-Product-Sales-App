class Chat {
  final int userId;
  final String userName;
  final String image;
  final String lastMessage;
  final String time;
  final int unreadCount;

  Chat({
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.image,
    required this.time,
    required this.unreadCount,
  });
}
