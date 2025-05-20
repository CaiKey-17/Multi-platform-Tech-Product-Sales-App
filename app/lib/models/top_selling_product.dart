class TopSellingProductDTO {
  final int productId;
  final String productName;
  final int totalSold;

  TopSellingProductDTO({
    required this.productId,
    required this.productName,
    required this.totalSold,
  });

  factory TopSellingProductDTO.fromJson(Map<String, dynamic> json) {
    return TopSellingProductDTO(
      productId: json['productId'],
      productName: json['productName'],
      totalSold: json['totalSold'],
    );
  }
}
