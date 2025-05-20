import 'package:json_annotation/json_annotation.dart';

part 'category_sales.g.dart';

@JsonSerializable()
class CategorySalesProjection {
  final String thoiGian;
  final String tenLoaiSanPham;
  final int tongSanPham;

  CategorySalesProjection({
    required this.thoiGian,
    required this.tenLoaiSanPham,
    required this.tongSanPham,
  });

  factory CategorySalesProjection.fromJson(Map<String, dynamic> json) =>
      _$CategorySalesProjectionFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySalesProjectionToJson(this);
}
