import 'package:app/globals/ip.dart';
import 'package:app/luan/models/bill_info.dart';
import 'package:app/luan/models/brand_info.dart';
import 'package:app/luan/models/category_info.dart';
import 'package:app/luan/models/order_info.dart';
import 'package:app/luan/models/product_color_info.dart';
import 'package:app/luan/models/product_image_info.dart';
import 'package:app/luan/models/product_info.dart';
import 'package:app/luan/models/product_variant_info.dart';
import 'package:app/luan/models/user_info.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'api_admin_service.g.dart';

class ApiResponse<T> {
  final int code;
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

@RestApi(baseUrl: ApiConfig.baseUrlAPI)
abstract class ApiAdminService {
  factory ApiAdminService(Dio dio, {String baseUrl}) = _ApiAdminService;

  // Brand
  @GET("/admin/brand/list")
  Future<List<BrandInfo>> getAllBrands();

  @GET("/admin/brand/names")
  Future<List<String>> getAllBrandNames();

  @POST("/admin/brand/add")
  Future<BrandInfo> createBrand(
    @Query("name") String name,
    @Query("image") String image,
  );

  @POST("/admin/brand/{name}")
  Future<BrandInfo> updateBrand(
    @Path("name") String name,
    @Query("image") String image,
  );

  @DELETE("/admin/brand/{name}")
  Future<void> deleteBrand(@Path("name") String name);

  // Category
  @GET("/admin/category/list")
  Future<List<CategoryInfo>> getAllCategories();

  @GET("/admin/category/names")
  Future<List<String>> getAllCategoryNames();

  @POST("/admin/category/add")
  Future<CategoryInfo> createCategory(
    @Query("name") String name,
    @Query("image") String image,
  );

  @POST("/admin/category/{name}")
  Future<CategoryInfo> updateCategory(
    @Path("name") String name,
    @Query("image") String image,
  );

  @DELETE("/admin/category/{name}")
  Future<void> deleteCategory(@Path("name") String name);

  // User
  @GET("/admin/users")
  Future<List<UserInfo>> getAllUsers();

  @GET("/admin/users/{id}")
  Future<UserInfo> getUserById(@Path("id") int id);

  @POST("/admin/users/{id}/toggle-active")
  Future<void> toggleUserActive(@Path("id") int id);

  @DELETE("/admin/users/{id}")
  Future<void> deleteUser(@Path("id") int id);

  @POST("/admin/users/{id}/full-name")
  Future<void> updateUserFullName(
    @Path("id") int id,
    @Query("fullName") String fullName,
  );

  // Order
  @GET("/admin/orders")
  Future<List<OrderInfo>> getAllOrders();

  @GET("/admin/orders/customer/{customerId}")
  Future<List<OrderInfo>> getOrdersByCustomer(
    @Path("customerId") int customerId,
  );

  @GET("/admin/orders/{orderId}")
  Future<OrderInfo> getOrderById(@Path("orderId") int orderId);

  @PUT("/admin/orders/{orderId}/process")
  Future<void> updateOrderProcess(
    @Path("orderId") int orderId,
    @Query("process") String process,
  );

  @GET("/admin/orders/coupon/{couponId}")
  Future<List<OrderInfo>> getOrdersByCouponId(@Path("couponId") int couponId);

  //Bill
  @GET("/admin/bills")
  Future<List<BillInfo>> getAllBills();

  @GET("/admin/bills/order/{orderId}")
  Future<List<BillInfo>> getBillsByOrder(@Path("orderId") int orderId);

  @GET("/admin/bills/{billId}")
  Future<BillInfo> getBillById(@Path("billId") int billId);

  @PUT("/admin/bills/{billId}/status")
  Future<void> updateBillStatus(
    @Path("billId") int billId,
    @Query("statusOrder") String statusOrder,
  );

  // Product
  @GET("/admin/products")
  Future<List<ProductInfo>> getAllProducts();

  @GET("/admin/products/{id}")
  Future<ProductInfo> getProductById(@Path("id") int id);

  @POST("/admin/products")
  Future<ProductInfo> createProduct(@Body() ProductInfo product);

  @PUT("/admin/products/{id}")
  Future<ProductInfo> updateProduct(
    @Path("id") int id,
    @Body() ProductInfo product,
  );

  @DELETE("/admin/products/{id}")
  Future<void> deleteProduct(@Path("id") int id);

  // Variant
  @GET("/admin/products/product_variant/{fkVariantProduct}")
  Future<List<ProductVariant>> getVariantsByProductId(
    @Path("fkVariantProduct") int fkVariantProduct,
  );

  @POST("/admin/products/product_variant")
  Future<ProductVariant> createProductVariant(@Body() ProductVariant variant);

  @PUT("/admin/products/product_variant/{id}")
  Future<ProductVariant> updateProductVariant(
    @Path("id") int id,
    @Body() ProductVariant variant,
  );

  @DELETE("/admin/products/product_variant/{id}")
  Future<void> deleteProductVariant(@Path("id") int id);

  // Color
  @GET("/admin/products/product_color/{fkVariantProduct}")
  Future<List<ProductColor>> getColorsByVariantId(
    @Path("fkVariantProduct") int fkVariantProduct,
  );

  @POST("/admin/products/product_color")
  Future<ProductColor> createProductColor(@Body() ProductColor color);

  @PUT("/admin/products/product_color/{id}")
  Future<ProductColor> updateProductColor(
    @Path("id") int id,
    @Body() ProductColor color,
  );

  @DELETE("/admin/products/product_color/{id}")
  Future<void> deleteProductColor(@Path("id") int id);

  // Image
  @GET("/admin/products/product_images/{fkImageProduct}")
  Future<List<ProductImage>> getImagesByProduct(
    @Path("fkImageProduct") int fkImageProduct,
  );

  @POST("/admin/products/product_images")
  Future<ProductImage> createProductImage(@Body() ProductImage image);

  @DELETE("/admin/products/product_images/{id}")
  Future<void> deleteProductImage(@Path("id") int id);

  @DELETE("/admin/products/product_images/fk/{fkImageProduct}")
  Future<void> deleteImagesByFkImageProduct(
    @Path("fkImageProduct") int fkImageProduct,
  );
}
