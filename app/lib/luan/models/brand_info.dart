class BrandInfo {
  final String? name;
  final String? image;

  BrandInfo({this.name, this.image});

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    print('Received JSON: $json'); 
    return BrandInfo(
      name: json['name'] as String?,
      image: json['images'] as String?, 
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'images': image,
    };
  }
}
