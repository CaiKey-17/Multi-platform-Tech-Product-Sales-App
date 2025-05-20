class ColorOption {
  final int id;
  final String nameColor;
  final double price;
  final String image;

  ColorOption({
    required this.id,
    required this.nameColor,
    required this.price,
    required this.image,
  });

  factory ColorOption.fromJson(Map<String, dynamic> json) {
    return ColorOption(
      id: json['id'],
      nameColor: json['name_color'],
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }
}
