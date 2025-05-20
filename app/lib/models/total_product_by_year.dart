import 'package:json_annotation/json_annotation.dart';

part 'total_product_by_year.g.dart';

@JsonSerializable()
class TotalProductByYear {
  final String thoiGian;
  final int tongSanPham;

  TotalProductByYear({required this.thoiGian, required this.tongSanPham});

  factory TotalProductByYear.fromJson(Map<String, dynamic> json) =>
      _$TotalProductByYearFromJson(json);

  Map<String, dynamic> toJson() => _$TotalProductByYearToJson(this);
}
