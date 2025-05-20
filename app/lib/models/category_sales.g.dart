// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_sales.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorySalesProjection _$CategorySalesProjectionFromJson(
        Map<String, dynamic> json) =>
    CategorySalesProjection(
      thoiGian: json['thoiGian'] as String,
      tenLoaiSanPham: json['tenLoaiSanPham'] as String,
      tongSanPham: (json['tongSanPham'] as num).toInt(),
    );

Map<String, dynamic> _$CategorySalesProjectionToJson(
        CategorySalesProjection instance) =>
    <String, dynamic>{
      'thoiGian': instance.thoiGian,
      'tenLoaiSanPham': instance.tenLoaiSanPham,
      'tongSanPham': instance.tongSanPham,
    };
