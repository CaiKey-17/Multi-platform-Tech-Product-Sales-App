import 'package:json_annotation/json_annotation.dart';

part 'valid_request.g.dart';

@JsonSerializable()
class ValidRequest {
  final String address;
  final String codes;
  final String email;
  final String password;
  final String otp;
  final String fullname;

  ValidRequest({
    required this.email,
    required this.password,
    required this.address,
    required this.codes,
    required this.otp,
    required this.fullname,
  });

  factory ValidRequest.fromJson(Map<String, dynamic> json) =>
      _$ValidRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ValidRequestToJson(this);
}
