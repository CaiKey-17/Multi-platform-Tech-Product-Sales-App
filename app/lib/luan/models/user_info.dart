class UserInfo {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final List<String> addresses;
  final int active;
  final String? tempId;
  final String createdAt;
  final int points;
  final List<String> codes;
  final String image;

  UserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.addresses,
    required this.active,
    this.tempId,
    required this.createdAt,
    required this.points,
    required this.codes,
    required this.image,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      addresses: List<String>.from(json['addresses'] ?? []),
      active: json['active'] ?? 0,
      tempId: json['tempId'],
      createdAt: json['createdAt'] ?? '',
      points: json['points'] ?? 0,
      codes: List<String>.from(json['codes'] ?? []),
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'addresses': addresses,
      'active': active,
      'tempId': tempId,
      'createdAt': createdAt,
      'points': points,
      'codes': codes,
      'image': image,
    };
  }

  @override
  String toString() {
    return 'UserInfo{id: $id, email: $email, fullName: $fullName, role: $role, addresses: $addresses, active: $active, tempId: $tempId, createdAt: $createdAt, points: $points, codes: $codes, image: $image}';
  }
}
