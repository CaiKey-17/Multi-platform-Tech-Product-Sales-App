class ProductVariant {
  final int id;
  final String nameVariant;
  final double? importPrice;
  final int? quantity;
  final double? originalPrice;
  final int? discountPercent;
  final double? price; // Nullable, chỉ dùng để hiển thị cục bộ
  final int fkVariantProduct;

  ProductVariant({
    required this.id,
    required this.nameVariant,
    this.importPrice,
    this.quantity,
    this.originalPrice,
    this.discountPercent,
    this.price,
    required this.fkVariantProduct,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      nameVariant: json['nameVariant'],
      importPrice: json['importPrice']?.toDouble(),
      quantity: json['quantity'],
      originalPrice: json['originalPrice']?.toDouble(),
      discountPercent: json['discountPercent'],
      price: json['price']?.toDouble(),
      fkVariantProduct: json['fkVariantProduct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameVariant': nameVariant,
      'importPrice': importPrice,
      'quantity': quantity,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'fkVariantProduct': fkVariantProduct,
    };
  }
}