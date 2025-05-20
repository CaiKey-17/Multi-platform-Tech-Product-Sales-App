import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class AddressList {
  final int? id;
  final String address;
  final String codes;
  final int userId;
  int status;

  AddressList({
    required this.id,
    required this.address,
    required this.codes,
    required this.userId,
    required this.status,
  });

  AddressList.noId({
    required this.address,
    required this.codes,
    required this.userId,
    required this.status,
  }) : id = null;

  factory AddressList.fromJson(Map<String, dynamic> json) =>
      _$AddressListFromJson(json);
  Map<String, dynamic> toJson() => _$AddressListToJson(this);
}
