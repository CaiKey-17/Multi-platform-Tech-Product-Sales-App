import 'package:json_annotation/json_annotation.dart';

part 'product_info.g.dart';

@JsonSerializable()
class ProductInfo {
  final int id;
  final String image;
  final String discountLabel;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final int discountPercent;
  final int idVariant;
  final int idColor;
  final double rating;

  ProductInfo({
    required this.id,
    required this.image,
    required this.discountLabel,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.idVariant,
    required this.idColor,
    required this.rating,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductInfoToJson(this);
}
