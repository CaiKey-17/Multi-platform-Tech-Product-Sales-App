class OrderInfo {
  final int id;
  final int? quantityTotal;
  final double? priceTotal;
  final double? couponTotal;
  final double? pointTotal;
  final double? ship;
  final double? tax;
  final String? createdAt;
  final String? address;
  final String? email;
  final double? total;
  String? process;
  final int? idFkCustomer;
  final int? idFkProductVariant;
  final int? fkCouponId;

  OrderInfo({
    required this.id,
    this.quantityTotal,
    this.priceTotal,
    this.couponTotal,
    this.pointTotal,
    this.ship,
    this.tax,
    this.createdAt,
    this.address,
    this.email,
    this.total,
    this.process,
    this.idFkCustomer,
    this.idFkProductVariant,
    this.fkCouponId,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: json['id'],
      quantityTotal: json['quantityTotal'],
      priceTotal: (json['priceTotal'] as num?)?.toDouble(),
      couponTotal: (json['couponTotal'] as num?)?.toDouble(),
      pointTotal: (json['pointTotal'] as num?)?.toDouble(),
      ship: (json['ship'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      createdAt: json['createdAt'],
      address: json['address'],
      email: json['email'],
      total: (json['total'] as num?)?.toDouble(),
      process: json['process'],
      idFkCustomer: json['id_fk_customer'],
      idFkProductVariant: json['id_fk_product_variant'],
      fkCouponId: json['fk_couponId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantityTotal': quantityTotal,
      'priceTotal': priceTotal,
      'couponTotal': couponTotal,
      'pointTotal': pointTotal,
      'ship': ship,
      'tax': tax,
      'createdAt': createdAt,
      'address': address,
      'email': email,
      'total': total,
      'process': process,
      'id_fk_customer': idFkCustomer,
      'id_fk_product_variant': idFkProductVariant,
      'fk_couponId': fkCouponId,
    };
  }

  @override
  String toString() {
    return 'OrderInfo{id: $id, quantityTotal: $quantityTotal, priceTotal: $priceTotal, couponTotal: $couponTotal, pointTotal: $pointTotal, ship: $ship, tax: $tax, createdAt: $createdAt, address: $address, email: $email, total: $total, process: $process, idFkCustomer: $idFkCustomer, idFkProductVariant: $idFkProductVariant, fkCouponId: $fkCouponId}';
  }
}