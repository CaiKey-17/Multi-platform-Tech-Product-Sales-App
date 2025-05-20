import 'package:json_annotation/json_annotation.dart';

part 'coupon_admin_info.g.dart';

@JsonSerializable()
class CouponAdmin {
  final int code;
  final String message;
  final List<CouponAdminData> data;

  CouponAdmin({required this.code, required this.message, required this.data});

  factory CouponAdmin.fromJson(Map<String, dynamic> json) =>
      _$CouponAdminFromJson(json);
  Map<String, dynamic> toJson() => _$CouponAdminToJson(this);
}

@JsonSerializable()
class CouponAdminData {
  final int id;
  final String name;
  final int couponValue;
  final int maxAllowedUses;
  final int usedCount;
  final String createdAt;
  final int minOrderValue;

  CouponAdminData({
    required this.id,
    required this.name,
    required this.couponValue,
    required this.maxAllowedUses,
    required this.usedCount,
    required this.createdAt,
    required this.minOrderValue,
  });

  factory CouponAdminData.fromJson(Map<String, dynamic> json) =>
      _$CouponAdminDataFromJson(json);
  Map<String, dynamic> toJson() => _$CouponAdminDataToJson(this);
}
