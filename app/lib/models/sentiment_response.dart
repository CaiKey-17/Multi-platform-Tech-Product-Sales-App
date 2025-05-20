import 'package:json_annotation/json_annotation.dart';

class SentimentResponse {
  final String result;

  SentimentResponse({required this.result});

  factory SentimentResponse.fromJson(Map<String, dynamic> json) {
    return SentimentResponse(result: json['result'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'result': result};
  }
}
