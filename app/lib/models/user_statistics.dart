class UserStatistics {
  final int totalUsers;
  final int newUsers;

  UserStatistics({required this.totalUsers, required this.newUsers});

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['total_users'],
      newUsers: json['new_users'],
    );
  }
}
