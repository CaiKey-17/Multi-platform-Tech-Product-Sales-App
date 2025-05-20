class BillInfo {
  final int? id;
  final String? createdAt;
  final String? createdReceive;
  final String? statusOrder;
  final String? methodPayment;
  final int? fkOrderId;

  BillInfo({
    this.id,
    this.createdAt,
    this.createdReceive,
    this.statusOrder,
    this.methodPayment,
    this.fkOrderId,
  });

  factory BillInfo.fromJson(Map<String, dynamic> json) {
    print('Received JSON: $json');
    return BillInfo(
      id: json['id'] as int?,
      createdAt: json['createdAt'] as String?,
      createdReceive: json['createdReceive'] as String?,
      statusOrder: json['statusOrder'] as String?,
      methodPayment: json['methodPayment'] as String?,
      fkOrderId: json['fkOrderId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'createdReceive': createdReceive,
      'statusOrder': statusOrder,
      'methodPayment': methodPayment,
      'fkOrderId': fkOrderId,
    };
  }
}