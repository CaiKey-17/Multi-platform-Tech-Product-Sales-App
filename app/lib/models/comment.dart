class Comment {
  final int id;
  final String username;
  final String content;
  final DateTime createdAt;
  final List<Comment> replies;
  final int productId;
  final String role;
  final int parentCommentId;
  final int daysAgo;

  Comment({
    required this.id,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.role,
    required this.replies,
    required this.parentCommentId,
    required this.productId,
    required this.daysAgo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      username: json['username'],
      content: json['content'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      replies:
          (json['replies'] as List).map((e) => Comment.fromJson(e)).toList(),
      productId: json['productId'] ?? 0,
      parentCommentId: json['parentCommentId'] ?? 0,
      daysAgo: json['daysAgo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies.map((e) => e.toJson()).toList(),
      'productId': productId,
      'role': role,
      'parentCommentId': parentCommentId,
      'daysAgo': daysAgo,
    };
  }
}
