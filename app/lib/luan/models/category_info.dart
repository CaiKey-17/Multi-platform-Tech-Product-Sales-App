class CategoryInfo{
  final String? name;
  final String? image;

  CategoryInfo({this.name, this.image});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    print('Received JSON: $json'); 
    return CategoryInfo(
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
