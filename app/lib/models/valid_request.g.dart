// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valid_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidRequest _$ValidRequestFromJson(Map<String, dynamic> json) => ValidRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      address: json['address'] as String,
      codes: json['codes'] as String,
      otp: json['otp'] as String,
      fullname: json['fullname'] as String,
    );

Map<String, dynamic> _$ValidRequestToJson(ValidRequest instance) =>
    <String, dynamic>{
      'address': instance.address,
      'codes': instance.codes,
      'email': instance.email,
      'password': instance.password,
      'otp': instance.otp,
      'fullname': instance.fullname,
    };
