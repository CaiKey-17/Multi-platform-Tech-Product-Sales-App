import 'image_model.dart';
import 'variant_model.dart';

class Product {
  final int id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String detail;
  final List<ProductImage> images;
  final List<Variant> variants;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.detail,
    required this.images,
    required this.variants,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      category: json['category'],
      description: json['description'],
      detail: json['detail'],
      images:
          (json['images'] as List)
              .map((i) => ProductImage.fromJson(i))
              .toList(),
      variants:
          (json['variants'] as List).map((v) => Variant.fromJson(v)).toList(),
      rating: json['rating'],
    );
  }
}
