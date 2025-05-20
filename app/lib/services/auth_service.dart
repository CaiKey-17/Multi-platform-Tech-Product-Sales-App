import 'package:app/models/admin_info.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user_info.dart';

class AuthRepository {
  final Dio _dio = Dio();
  late ApiService _apiService;

  AuthRepository() {
    _apiService = ApiService(_dio);
  }

  Future<bool> fetchUserInfo(String token, String role) async {
    try {
      UserInfo userInfo = await _apiService.getUserInfo("Bearer $token");

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setInt('userId', userInfo.id);
      await prefs.setString('email', userInfo.email);
      await prefs.setString('fullName', userInfo.fullName);
      await prefs.setString('role', userInfo.role);
      await prefs.setStringList('addresses', userInfo.addresses);
      await prefs.setStringList('codes', userInfo.codes);
      await prefs.setBool('active', userInfo.active == 1);
      await prefs.setString('createdAt', userInfo.createdAt);
      await prefs.setInt('points', userInfo.points);
      await prefs.setString('image', userInfo.image);

      return true;
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
      return false;
    }
  }

  Future<bool> fetchAdminInfo(String token, String role) async {
    try {
      AdminInfo userInfo = await _apiService.getAdminInfo("Bearer $token");

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setInt('userId', userInfo.id);
      await prefs.setString('email', userInfo.email);
      await prefs.setString('fullName', userInfo.fullName);
      await prefs.setString('role', userInfo.role);
      await prefs.setBool('active', userInfo.active == 1);
      await prefs.setString('image', userInfo.image);

      return true;
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
      return false;
    }
  }
}
