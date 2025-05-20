// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingInfo _$RatingInfoFromJson(Map<String, dynamic> json) => RatingInfo(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      rating: (json['rating'] as num).toInt(),
      content: json['content'] as String,
      sentiment: (json['sentiment'] as num).toInt(),
      idFkCustomer: (json['id_fk_customer'] as num).toInt(),
      idFkProduct: (json['id_fk_product'] as num).toInt(),
    );

Map<String, dynamic> _$RatingInfoToJson(RatingInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'rating': instance.rating,
      'content': instance.content,
      'sentiment': instance.sentiment,
      'id_fk_customer': instance.idFkCustomer,
      'id_fk_product': instance.idFkProduct,
    };
