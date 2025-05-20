class CommentRequest {
  final String username;
  final String content;
  final int? productId;
  final String role;

  CommentRequest({
    required this.username,
    required this.content,
    required this.role,
    this.productId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content,
      'productId': productId,
      'role': role,
    };
  }
}
