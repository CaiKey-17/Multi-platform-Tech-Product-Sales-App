import 'package:app/models/comment.dart';

class CommentInfo {
  final List<Comment> comments;

  CommentInfo({required this.comments});

  factory CommentInfo.fromJson(Map<String, dynamic> json) {
    return CommentInfo(
      comments:
          (json['comments'] as List).map((e) => Comment.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'comments': comments.map((e) => e.toJson()).toList()};
  }
}
