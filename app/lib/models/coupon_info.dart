import 'package:json_annotation/json_annotation.dart';

part 'coupon_info.g.dart';

@JsonSerializable()
class Coupon {
  final int code;
  final String message;
  final CouponData? data;

  Coupon({required this.code, required this.message, this.data});

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
  Map<String, dynamic> toJson() => _$CouponToJson(this);
}

@JsonSerializable()
class CouponData {
  final int id;
  final String name;
  final double couponValue;

  CouponData({required this.id, required this.name, required this.couponValue});

  factory CouponData.fromJson(Map<String, dynamic> json) =>
      _$CouponDataFromJson(json);
  Map<String, dynamic> toJson() => _$CouponDataToJson(this);
}
