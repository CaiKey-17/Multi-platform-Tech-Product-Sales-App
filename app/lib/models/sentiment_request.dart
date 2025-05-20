import 'package:json_annotation/json_annotation.dart';

class SentimentRequest {
  final String text;

  SentimentRequest({required this.text});

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}
