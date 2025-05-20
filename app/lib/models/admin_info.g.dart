// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminInfo _$AdminInfoFromJson(Map<String, dynamic> json) => AdminInfo(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      active: (json['active'] as num).toInt(),
      image: json['image'] as String,
    );

Map<String, dynamic> _$AdminInfoToJson(AdminInfo instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': instance.role,
      'active': instance.active,
      'image': instance.image,
    };
