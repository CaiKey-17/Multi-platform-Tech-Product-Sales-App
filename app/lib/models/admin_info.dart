import 'package:json_annotation/json_annotation.dart';

part 'admin_info.g.dart';

@JsonSerializable()
class AdminInfo {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final int active;
  final String image;

  AdminInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.active,
    required this.image,
  });

  factory AdminInfo.fromJson(Map<String, dynamic> json) =>
      _$AdminInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AdminInfoToJson(this);
}
