class OrderStatisticsDTO {
  final int countOrder;
  final int totalRevenue;

  OrderStatisticsDTO({required this.countOrder, required this.totalRevenue});

  factory OrderStatisticsDTO.fromMap(Map<String, dynamic> map) {
    return OrderStatisticsDTO(
      countOrder: map['countOrder'],
      totalRevenue: map['totalRevenue'],
    );
  }

  factory OrderStatisticsDTO.fromJson(Map<String, dynamic> json) {
    return OrderStatisticsDTO(
      countOrder: json['countOrder'],
      totalRevenue: json['totalRevenue'],
    );
  }
}
