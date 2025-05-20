class CommentReplyRequest {
  final String username;
  final String content;
  final int? commentId;
  final String role;

  CommentReplyRequest({
    required this.username,
    required this.content,
    this.commentId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content,
      'commentId': commentId,
      'role': role,
    };
  }
}
