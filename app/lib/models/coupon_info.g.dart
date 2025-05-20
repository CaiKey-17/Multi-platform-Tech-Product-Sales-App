// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coupon _$CouponFromJson(Map<String, dynamic> json) => Coupon(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : CouponData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CouponToJson(Coupon instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

CouponData _$CouponDataFromJson(Map<String, dynamic> json) => CouponData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      couponValue: (json['couponValue'] as num).toDouble(),
    );

Map<String, dynamic> _$CouponDataToJson(CouponData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'couponValue': instance.couponValue,
    };
