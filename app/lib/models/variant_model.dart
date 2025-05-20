import 'color_model.dart';

class Variant {
  final int id;
  final String name;
  final int discountPercent;
  final double oldPrice;
  final double price;
  final List<ColorOption> colors;

  Variant({
    required this.id,
    required this.name,
    required this.discountPercent,
    required this.oldPrice,
    required this.price,
    required this.colors,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'],
      name: json['name'],
      discountPercent: json['discountPercent'],
      oldPrice: json['oldPrice'].toDouble(),
      price: json['price'].toDouble(),
      colors:
          (json['colors'] as List).map((c) => ColorOption.fromJson(c)).toList(),
    );
  }
}
