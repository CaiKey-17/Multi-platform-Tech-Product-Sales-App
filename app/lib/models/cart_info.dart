import 'package:json_annotation/json_annotation.dart';

part 'cart_info.g.dart';

@JsonSerializable()
class CartInfo {
  final int orderId;
  final int orderDetailId;
  final int fkColorId;
  final int fkProductId;
  final int productId;
  double price;
  double originalPrice;
  int quantity;
  double total;
  final String image;
  final String colorName;
  final String nameVariant;

  @JsonKey(defaultValue: false)
  bool selected;

  CartInfo({
    required this.orderId,
    required this.orderDetailId,
    required this.fkColorId,
    required this.fkProductId,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.total,
    required this.image,
    required this.colorName,
    required this.nameVariant,
    required this.productId,
    this.selected = false,
  });

  factory CartInfo.fromJson(Map<String, dynamic> json) =>
      _$CartInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CartInfoToJson(this);
}
