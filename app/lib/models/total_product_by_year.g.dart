// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_product_by_year.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotalProductByYear _$TotalProductByYearFromJson(Map<String, dynamic> json) =>
    TotalProductByYear(
      thoiGian: json['thoiGian'] as String,
      tongSanPham: (json['tongSanPham'] as num).toInt(),
    );

Map<String, dynamic> _$TotalProductByYearToJson(TotalProductByYear instance) =>
    <String, dynamic>{
      'thoiGian': instance.thoiGian,
      'tongSanPham': instance.tongSanPham,
    };
