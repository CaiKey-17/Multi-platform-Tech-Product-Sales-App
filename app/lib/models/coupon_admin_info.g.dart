// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_admin_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponAdmin _$CouponAdminFromJson(Map<String, dynamic> json) => CouponAdmin(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => CouponAdminData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CouponAdminToJson(CouponAdmin instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

CouponAdminData _$CouponAdminDataFromJson(Map<String, dynamic> json) =>
    CouponAdminData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      couponValue: (json['couponValue'] as num).toInt(),
      maxAllowedUses: (json['maxAllowedUses'] as num).toInt(),
      usedCount: (json['usedCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      minOrderValue: (json['minOrderValue'] as num).toInt(),
    );

Map<String, dynamic> _$CouponAdminDataToJson(CouponAdminData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'couponValue': instance.couponValue,
      'maxAllowedUses': instance.maxAllowedUses,
      'usedCount': instance.usedCount,
      'createdAt': instance.createdAt,
      'minOrderValue': instance.minOrderValue,
    };
