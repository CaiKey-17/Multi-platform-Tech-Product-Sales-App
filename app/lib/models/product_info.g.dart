// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductInfo _$ProductInfoFromJson(Map<String, dynamic> json) => ProductInfo(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String,
      discountLabel: json['discountLabel'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['oldPrice'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num).toInt(),
      idVariant: (json['idVariant'] as num).toInt(),
      idColor: (json['idColor'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductInfoToJson(ProductInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'discountLabel': instance.discountLabel,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'oldPrice': instance.oldPrice,
      'discountPercent': instance.discountPercent,
      'idVariant': instance.idVariant,
      'idColor': instance.idColor,
      'rating': instance.rating,
    };
