// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      address: json['address'] as String,
      fullname: json['fullname'] as String,
      codes: json['codes'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'address': instance.address,
      'email': instance.email,
      'password': instance.password,
      'fullname': instance.fullname,
      'codes': instance.codes,
    };
