class ProductInfo {
  final int? id;
  final String? name;
  final String? shortDescription;
  final String? detail;
  final DateTime? createdAt;
  final String? mainImage;
  final bool hasColor;
  final String? fkBrand;
  final String? fkCategory;

  ProductInfo({
    this.id,
    this.name,
    this.shortDescription,
    this.detail,
    this.createdAt,
    this.mainImage,
    this.hasColor = true,
    this.fkBrand,
    this.fkCategory,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'],
      name: json['name'],
      shortDescription: json['shortDescription'],
      detail: json['detail'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      mainImage: json['mainImage'],
      hasColor: json['hasColor'] ?? true,
      fkBrand: json['fkBrand'],
      fkCategory: json['fkCategory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'detail': detail,
      'created_at': createdAt?.toIso8601String(),
      'mainImage': mainImage,
      'hasColor': hasColor,
      'fkBrand': fkBrand,
      'fkCategory': fkCategory,
    };
  }
}
