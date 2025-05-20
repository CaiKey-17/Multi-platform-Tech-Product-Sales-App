// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartInfo _$CartInfoFromJson(Map<String, dynamic> json) => CartInfo(
      orderId: (json['orderId'] as num).toInt(),
      orderDetailId: (json['orderDetailId'] as num).toInt(),
      fkColorId: (json['fkColorId'] as num).toInt(),
      fkProductId: (json['fkProductId'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      image: json['image'] as String,
      colorName: json['colorName'] as String,
      nameVariant: json['nameVariant'] as String,
      productId: (json['productId'] as num).toInt(),
      selected: json['selected'] as bool? ?? false,
    );

Map<String, dynamic> _$CartInfoToJson(CartInfo instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'orderDetailId': instance.orderDetailId,
      'fkColorId': instance.fkColorId,
      'fkProductId': instance.fkProductId,
      'productId': instance.productId,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'quantity': instance.quantity,
      'total': instance.total,
      'image': instance.image,
      'colorName': instance.colorName,
      'nameVariant': instance.nameVariant,
      'selected': instance.selected,
    };
