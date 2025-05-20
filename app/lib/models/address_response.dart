import 'package:json_annotation/json_annotation.dart';
import 'address.dart'; // import AddressList

part 'address_response.g.dart';

@JsonSerializable()
class AddressResponse {
  final String message;
  final AddressList data;

  AddressResponse({required this.message, required this.data});

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressResponseToJson(this);
}
