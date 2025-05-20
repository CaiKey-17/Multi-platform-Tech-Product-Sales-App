import 'package:dio/dio.dart';
import '../services/api_service.dart';

class CartRepository {
  final ApiService apiService;

  CartRepository(this.apiService);

  Future<Map<String, dynamic>> addToCart({
    String? token,
    required int productId,
    required int colorId,
    required int quantity,
    int? id,
  }) async {
    try {
      String? authToken;
      if (id == null && token != null && token.isNotEmpty) {
        authToken = "Bearer $token";
      }

      final response = await apiService.addToCart(
        authToken,
        productId,
        colorId,
        quantity,
        id,
      );

      print("✅ Phản hồi API: $response");

      return response;
    } on DioException catch (e) {
      print("❌ Lỗi API: ${e.response?.data ?? e.message}");

      return {
        "error": e.response?.data["error"] ?? "Không thể thêm vào giỏ hàng",
        "statusCode": e.response?.statusCode ?? 500,
      };
    } catch (e) {
      print("⚠️ Lỗi không xác định: $e");

      return {"error": "Lỗi hệ thống! Vui lòng thử lại.", "statusCode": 500};
    }
  }

  Future<Map<String, dynamic>> minusToCart({
    required int productId,
    required int orderId,
    required int colorId,
  }) async {
    try {
      final response = await apiService.minusToCart(
        productId,
        orderId,
        colorId,
      );

      print("✅ Phản hồi API: $response");

      return response;
    } on DioException catch (e) {
      print("❌ Lỗi API: ${e.response?.data ?? e.message}");

      return {
        "error": e.response?.data["error"] ?? "Không thể trừ khỏi vào giỏ hàng",
        "statusCode": e.response?.statusCode ?? 500,
      };
    } catch (e) {
      print("⚠️ Lỗi không xác định: $e");

      return {"error": "Lỗi hệ thống! Vui lòng thử lại.", "statusCode": 500};
    }
  }

  Future<Map<String, dynamic>> deleteToCart({
    required int orderDetailId,
  }) async {
    try {
      final response = await apiService.deleteToCart(orderDetailId);
      print("✅ Phản hồi API: $response");

      return response;
    } on DioException catch (e) {
      print("❌ Lỗi API: ${e.response?.data ?? e.message}");

      return {
        "error": e.response?.data["error"] ?? "Không thể xoá khỏi vào giỏ hàng",
        "statusCode": e.response?.statusCode ?? 500,
      };
    } catch (e) {
      print("⚠️ Lỗi không xác định: $e");

      return {"error": "Lỗi hệ thống! Vui lòng thử lại.", "statusCode": 500};
    }
  }
}
