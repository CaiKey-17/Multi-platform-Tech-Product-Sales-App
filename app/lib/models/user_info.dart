import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final List<String> addresses;
  final int active;
  final String? tempId;
  final String createdAt;
  final int points;
  final List<String> codes;
  final String image;

  UserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.addresses,
    required this.active,
    this.tempId,
    required this.createdAt,
    required this.points,
    required this.codes,
    required this.image,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
