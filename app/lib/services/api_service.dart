import 'package:app/globals/ip.dart';
import 'package:app/models/category_sales.dart';
import 'package:app/models/total_product_by_year.dart';
import 'package:app/models/address.dart';
import 'package:app/models/address_response.dart';
import 'package:app/models/admin_info.dart';
import 'package:app/models/category_info.dart';
import 'package:app/models/comment.dart';
import 'package:app/models/comment_info.dart';
import 'package:app/models/comment_reply_request.dart';
import 'package:app/models/comment_request.dart';
import 'package:app/models/coupon_admin_info.dart';
import 'package:app/models/coupon_info.dart';
import 'package:app/models/order_statistics.dart';

import 'package:app/models/product_info.dart';
import 'package:app/models/product_info_detail.dart';
import 'package:app/models/rating_info.dart';
import 'package:app/models/resend_otp_request.dart';
import 'package:app/models/resend_otp_response.dart';
import 'package:app/models/top_selling_product.dart';
import 'package:app/models/valid_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/http.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

import '../models/register_request.dart';
import '../models/valid_request.dart';
import '../models/register_response.dart';
import '../models/user_info.dart';
import '../models/cart_info.dart';

part 'api_service.g.dart';

class ApiResponse<T> {
  final int? code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }
}

class ApiResponse1<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse1({required this.code, required this.message, this.data});

  factory ApiResponse1.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse1(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

class PerformanceDataDTO {
  final String thoiGian;
  final int tongSoDon;
  final double tongLoiNhuan;
  final double tongDoanhThu;

  PerformanceDataDTO({
    required this.thoiGian,
    required this.tongSoDon,
    required this.tongLoiNhuan,
    required this.tongDoanhThu,
  });

  factory PerformanceDataDTO.fromJson(Map<String, dynamic> json) {
    return PerformanceDataDTO(
      thoiGian: json['thoiGian'],
      tongSoDon: json['tongSoDon'],
      tongLoiNhuan: (json['tongLoiNhuan'] as num).toDouble(),
      tongDoanhThu: (json['tongDoanhThu'] as num).toDouble(),
    );
  }

  PerformanceData toPerformanceData() {
    return PerformanceData(thoiGian, tongSoDon, tongLoiNhuan, tongDoanhThu);
  }
}

class ProductDataDTO {
  final String category;
  final int quantity;

  ProductDataDTO({required this.category, required this.quantity});

  factory ProductDataDTO.fromJson(Map<String, dynamic> json) {
    return ProductDataDTO(
      category: json['category'],
      quantity: json['quantity'],
    );
  }

  ProductData toProductData() {
    return ProductData(category, quantity);
  }
}

class PerformanceData {
  final String period;
  final int orders;
  final double revenue;
  final double profit;

  PerformanceData(this.period, this.orders, this.revenue, this.profit);
}

class ProductData {
  final String category;
  final int quantity;

  ProductData(this.category, this.quantity);
}

@RestApi(baseUrl: ApiConfig.baseUrlAPI)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/auth/login")
  Future<LoginResponse> login(@Body() LoginRequest request);

  @POST("/auth/changePassword")
  Future<ApiResponse> changePassword(
    @Header("Authorization") String token,
    @Query("oldPassword") String oldPassword,
    @Query("newPassword") String newPassword,
  );

  @POST("/auth/register")
  Future<RegisterResponse> register(@Body() RegisterRequest request);

  @POST("/auth/verify-otp")
  Future<ValidResponse> verifyOtp(@Body() ValidRequest request);

  @POST("/auth/resend-otp")
  Future<ResendOtpResponse> resendOtp(@Body() ResendOtpRequest request);

  @GET("/auth/user-info")
  Future<UserInfo> getUserInfo(@Header("Authorization") String token);

  @GET("/auth/admin-info")
  Future<AdminInfo> getAdminInfo(@Header("Authorization") String token);

  @POST("/auth/user-info/change")
  Future<void> changeImage(
    @Header("Authorization") String token,
    @Query("image") String image,
  );

  @POST("/auth/user-info/update-name")
  Future<void> changeName(
    @Header("Authorization") String token,
    @Query("name") String name,
  );
  @GET("/address")
  Future<List<AddressList>> getListAddress(
    @Header("Authorization") String token,
  );
  @POST("/address/add")
  Future<AddressResponse> addAddress(@Body() AddressList address);

  @POST("/address/default")
  Future<void> chooseAddressDefault(
    @Header("Authorization") String token,
    @Query("addressId") int addressId,
  );

  @GET("/category/list")
  Future<List<CategoryInfo>> getListCategory();

  @GET("/brand/list")
  Future<List<CategoryInfo>> getListBrand();

  @GET("/products/promotion")
  Future<List<ProductInfo>> getProductsPromotion();

  @GET("/products/new")
  Future<List<ProductInfo>> getProductsNew();

  @GET("/products/best-seller")
  Future<List<ProductInfo>> getProductsBestSeller();

  @GET("/products/laptop")
  Future<List<ProductInfo>> getProductsLaptop();

  @GET("/products/phone")
  Future<List<ProductInfo>> getProductsPhone();

  @GET("/products/pc")
  Future<List<ProductInfo>> getProductsPc();

  @GET("/products/keyboard")
  Future<List<ProductInfo>> getProductsKeyBoard();

  @GET("/products/monitor")
  Future<List<ProductInfo>> getProductsMonitor();

  @GET("/products/category")
  Future<List<ProductInfo>> getProductsByCategory(
    @Query("fk_category") String fk_category,
  );

  @GET("/products/search")
  Future<List<ProductInfo>> getProductsBySearch(@Query("name") String name);

  @GET("/products/search-advance")
  Future<List<ProductInfo>> getProductsBySearchAdvance(
    @Query("name") String name,
    @Query("brand") String? brand,
    @Query("minPrice") double? minPrice,
    @Query("maxPrice") double? maxPrice,
    @Query("rating") double? rating,
  );

  @GET("/products/detail")
  Future<Product> getProductDetail(@Query("id") int id);

  @GET("/comments")
  Future<List<Comment>> getCommentInProduct(@Query("id") int id);

  @POST("/comments")
  Future<Comment> postComment(@Body() CommentRequest comment);

  @POST("/comments/{commentId}/reply")
  Future<Comment> replyToComment(
    @Path("commentId") int commentId,
    @Body() CommentReplyRequest reply,
  );

  @GET("/products/brand")
  Future<List<ProductInfo>> getProductsByBrand(
    @Query("fk_brand") String fk_brand,
  );

  @GET("/rating/product")
  Future<List<RatingInfo>> getRatingsByProduct(
    @Query("productId") int productId,
  );

  @POST("/rating/product/{productId}")
  Future<RatingInfo> createRating(
    @Path("productId") int productId,
    @Body() RatingInfo rating,
  );

  @GET("/cart/list")
  Future<List<CartInfo>> getItemInCart({
    @Header("Authorization") String? token,
    @Query("id") int? id,
  });

  @GET("/cart/list-detail")
  Future<List<CartInfo>> getItemInCartDetail({@Query("orderId") int? orderId});

  @GET("/cart/quantity")
  Future<Map<String, dynamic>> getRawQuantityInCart(
    @Query("userId") int? userId,
  );

  @POST("/auth/forgot-password")
  Future<void> sendResetPassword(@Query("email") String email);

  @GET("/coupon/find")
  Future<Coupon> findCoupon(
    @Query("name") String name,
    @Query("price") double price,
  );

  @GET("/coupon")
  Future<CouponAdmin> listCoupon();

  @POST("/coupon")
  Future<void> addCoupon(
    @Query("couponValue") int couponValue,
    @Query("maxAllowedUses") int maxAllowedUses,
    @Query("minOrderValue") int minOrderValue,
  );
  @POST("/coupon/delete")
  Future<void> deleteCoupon(@Query("id") int id);

  @POST("/cart/add")
  Future<Map<String, dynamic>> addToCart(
    @Header("Authorization") String? token,
    @Query("productId") int productId,
    @Query("colorId") int colorId,
    @Query("quantity") int quantity,
    @Query("id") int? id,
  );

  @POST("/cart/minus")
  Future<Map<String, dynamic>> minusToCart(
    @Query("productId") int productId,
    @Query("orderId") int orderId,
    @Query("colorId") int colorId,
  );

  @POST("/cart/delete")
  Future<Map<String, dynamic>> deleteToCart(
    @Query("orderDetailId") int orderDetailId,
  );

  @GET("/order/pending")
  Future<List<Map<String, dynamic>>> findPendingOrdersByCustomer(
    @Header("Authorization") String? token,
  );

  @GET("/order/delivering")
  Future<List<Map<String, dynamic>>> findDeliveringOrdersByCustomer(
    @Header("Authorization") String? token,
  );
  @GET("/order/delivered")
  Future<List<Map<String, dynamic>>> findDeliveredOrdersByCustomer(
    @Header("Authorization") String? token,
  );

  @POST("/order/confirm")
  Future<Map<String, dynamic>> confirmToCart(
    @Query("orderId") int orderId,
    @Query("address") String address,
    @Query("couponTotal") double couponTotal,
    @Query("email") String email,
    @Query("fkCouponId") int fkCouponId,
    @Query("pointTotal") double pointTotal,
    @Query("priceTotal") double priceTotal,
    @Query("ship") double ship,
    @Query("tempId") String tempId,
    @Query("id") int id,
  );

  @POST("/order/cancel")
  Future<ApiResponse> cancelToCart(@Query("orderId") int orderId);

  @POST("/order/accept")
  Future<ApiResponse> acceptToCart(@Query("orderId") int orderId);

  @POST("/order/received")
  Future<ApiResponse> received(@Query("orderId") int orderId);

  @GET("/statistic/user-stats")
  Future<ApiResponse<Map<String, dynamic>>> getUserStatistics();

  @GET("/statistic/order-stats")
  Future<ApiResponse<Map<String, dynamic>>> getOrderStatistics();

  @GET("/statistic/top-selling-products")
  Future<ApiResponse1<List<Map<String, dynamic>>>> getTopSellingProducts();

  @GET("/statistic/performance")
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceData(
    @Query("period") String period,
  );
  @GET("/statistic/performance-year")
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceDataByYear(
    @Query("year") int year,
  );

  @GET("/statistic/performance-year-quarter")
  Future<ApiResponse1<List<PerformanceDataDTO>>>
  getPerformanceDataByYearQuarter(
    @Query("year") int year,
    @Query("quarter") int quarter,
  );

  @GET("/statistic/performance-year-month")
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceDataByYearMonth(
    @Query("year") int year,
    @Query("month") int month,
  );
  @GET("/statistic/performance-year-week")
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceDataByYearWeek(
    @Query("year") int year,
    @Query("month") int month,
    @Query("week") int week,
  );

  @GET("/statistic/product-stats")
  Future<ApiResponse1<List<ProductDataDTO>>> getProductData(
    @Query("period") String period,
  );

  @GET("/statistic/performance/custom")
  Future<ApiResponse1<List<PerformanceDataDTO>>> getCustomPerformanceData(
    @Query("start") String start,
    @Query("end") String end,
  );

  @GET("/statistic/product-stats/custom")
  Future<ApiResponse1<List<ProductDataDTO>>> getCustomProductData(
    @Query("start") String start,
    @Query("end") String end,
  );

  @GET("/statistic/sold-products-by-year")
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYear();

  @GET("/statistic/sold-products-by-year-month")
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearMonth(
    @Query("year") int year,
  );

  @GET("/statistic/sold-products-by-year-month-v2")
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearMonthV2(
    @Query("year") int year,
    @Query("month") int month,
  );

  @GET("/statistic/sold-products-by-year-quarter")
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearQuarter(
    @Query("year") int year,
    @Query("quarter") int quarter,
  );

  @GET("/statistic/sold-products-by-year-month-week")
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearMonthWeek(
    @Query("year") int year,
    @Query("month") int month,
    @Query("week") int week,
  );

  @GET("/statistic/sold-products/custom")
  Future<ApiResponse1<List<TotalProductByYear>>> getTotalProductByDayBetween(
    @Query("start") String start,
    @Query("end") String end,
  );

  ///
  @GET("/statistic/sold-tpye-products-by-year")
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYear();

  @GET("/statistic/sold-type-products-by-year-month")
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearMonth(@Query("year") int year);

  @GET("/statistic/sold-type-products-by-year-month-v2")
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearMonthV2(
    @Query("year") int year,
    @Query("month") int month,
  );

  @GET("/statistic/sold-type-products-by-year-quarter")
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearQuarter(
    @Query("year") int year,
    @Query("quarter") int quarter,
  );

  @GET("/statistic/sold-type-products-by-year-month-week")
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearMonthWeek(
    @Query("year") int year,
    @Query("month") int month,
    @Query("week") int week,
  );

  @GET("/statistic/sold-type-products/custom")
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getTotalTypeProductByDayBetween(
    @Query("start") String start,
    @Query("end") String end,
  );
}
