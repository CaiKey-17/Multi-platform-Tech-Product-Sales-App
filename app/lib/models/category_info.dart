import 'package:json_annotation/json_annotation.dart';

part 'category_info.g.dart';

@JsonSerializable()
class CategoryInfo {
  final String name;
  final String? images;

  CategoryInfo({required this.name, this.images});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) =>
      _$CategoryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryInfoToJson(this);
}
