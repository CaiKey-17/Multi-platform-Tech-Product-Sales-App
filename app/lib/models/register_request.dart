import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String address;
  final String email;
  final String password;
  final String fullname;
  final String codes;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.address,
    required this.fullname,
    required this.codes,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
