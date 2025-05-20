// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      message: json['message'] as String,
      data: AddressList.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };
