import 'package:json_annotation/json_annotation.dart';

part 'valid_response.g.dart';

@JsonSerializable()
class ValidResponse {
  final int code;
  final String message;

  ValidResponse({required this.code, required this.message});

  factory ValidResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidResponseToJson(this);
}
