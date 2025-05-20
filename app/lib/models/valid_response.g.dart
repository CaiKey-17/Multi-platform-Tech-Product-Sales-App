// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valid_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidResponse _$ValidResponseFromJson(Map<String, dynamic> json) =>
    ValidResponse(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$ValidResponseToJson(ValidResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
