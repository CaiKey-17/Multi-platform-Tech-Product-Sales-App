// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressList _$AddressListFromJson(Map<String, dynamic> json) => AddressList(
      id: (json['id'] as num?)?.toInt(),
      address: json['address'] as String,
      codes: json['codes'] as String,
      userId: (json['userId'] as num).toInt(),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$AddressListToJson(AddressList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'codes': instance.codes,
      'userId': instance.userId,
      'status': instance.status,
    };
