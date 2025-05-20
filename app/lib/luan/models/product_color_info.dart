class ProductColor {
  final int id;
  final String colorName;
  final double colorPrice;
  final int? quantity;
  final String? image;
  final int fkVariantProduct; 

  ProductColor({
    required this.id,
    required this.colorName,
    required this.colorPrice,
    this.quantity,
    this.image,
    required this.fkVariantProduct,
  });

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      id: json['id'],
      colorName: json['colorName'],
      colorPrice: json['colorPrice'].toDouble(),
      quantity: json['quantity'],
      image: json['image'],
      fkVariantProduct: json['fkVariantProduct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colorName': colorName,
      'colorPrice': colorPrice,
      'quantity': quantity,
      'image': image,
      'fkVariantProduct': fkVariantProduct,
    };
  }
}