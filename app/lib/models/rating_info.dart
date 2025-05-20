import 'package:json_annotation/json_annotation.dart';

part 'rating_info.g.dart';

@JsonSerializable()
class RatingInfo {
  final int? id;
  final String name;
  final int rating;
  final String content;
  final int sentiment;

  @JsonKey(name: 'id_fk_customer')
  final int idFkCustomer;

  @JsonKey(name: 'id_fk_product')
  final int idFkProduct;

  RatingInfo({
    required this.id,
    required this.name,
    required this.rating,
    required this.content,
    required this.sentiment,
    required this.idFkCustomer,
    required this.idFkProduct,
  });

  RatingInfo.noId({
    required this.name,
    required this.rating,
    required this.content,
    required this.sentiment,
    required this.idFkCustomer,
    required this.idFkProduct,
  }) : id = null;

  factory RatingInfo.fromJson(Map<String, dynamic> json) =>
      _$RatingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$RatingInfoToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'content': content,
      'sentiment': sentiment,
      'id_fk_customer': idFkCustomer,
      'id_fk_product': idFkProduct,
    };
  }
}
