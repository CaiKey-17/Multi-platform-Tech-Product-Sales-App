// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      addresses:
          (json['addresses'] as List<dynamic>).map((e) => e as String).toList(),
      active: (json['active'] as num).toInt(),
      tempId: json['tempId'] as String?,
      createdAt: json['createdAt'] as String,
      points: (json['points'] as num).toInt(),
      codes: (json['codes'] as List<dynamic>).map((e) => e as String).toList(),
      image: json['image'] as String,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': instance.role,
      'addresses': instance.addresses,
      'active': instance.active,
      'tempId': instance.tempId,
      'createdAt': instance.createdAt,
      'points': instance.points,
      'codes': instance.codes,
      'image': instance.image,
    };
