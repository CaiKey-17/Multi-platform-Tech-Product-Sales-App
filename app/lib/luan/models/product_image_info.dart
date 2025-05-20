class ProductImage {
  final int? id;
  final String image;
  final int fkImageProduct;

  ProductImage({
    required this.id,
    required this.image,
    required this.fkImageProduct,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      fkImageProduct: json['fkImageProduct'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'fkImageProduct': fkImageProduct,
    };
  }
}