// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_admin_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ApiAdminService implements ApiAdminService {
  _ApiAdminService(this._dio, {this.baseUrl}) {
    baseUrl ??= ApiConfig.baseUrlAPI;
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<BrandInfo>> getAllBrands() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<BrandInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => BrandInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<String>> getAllBrandNames() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<String>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/names',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = _result.data!.cast<String>();
    return value;
  }

  @override
  Future<BrandInfo> createBrand(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name, r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<BrandInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = BrandInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<BrandInfo> updateBrand(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<BrandInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = BrandInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteBrand(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<CategoryInfo>> getAllCategories() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CategoryInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map(
              (dynamic i) => CategoryInfo.fromJson(i as Map<String, dynamic>),
            )
            .toList();
    return value;
  }

  @override
  Future<List<String>> getAllCategoryNames() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<String>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/names',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = _result.data!.cast<String>();
    return value;
  }

  @override
  Future<CategoryInfo> createCategory(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name, r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<CategoryInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = CategoryInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CategoryInfo> updateCategory(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<CategoryInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = CategoryInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteCategory(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<UserInfo>> getAllUsers() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<UserInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/users',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => UserInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<UserInfo> getUserById(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<UserInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/users/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = UserInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> toggleUserActive(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/users/${id}/toggle-active',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<void> deleteUser(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/users/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<void> updateUserFullName(id, fullName) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fullName': fullName};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/users/${id}/full-name',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<OrderInfo>> getAllOrders() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<OrderInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/orders',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => OrderInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<OrderInfo>> getOrdersByCustomer(customerId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<OrderInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/orders/customer/${customerId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => OrderInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<OrderInfo> getOrderById(orderId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<OrderInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/orders/${orderId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = OrderInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> updateOrderProcess(orderId, process) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'process': process};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'PUT', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/orders/${orderId}/process',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<OrderInfo>> getOrdersByCouponId(couponId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<OrderInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/orders/coupon/${couponId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => OrderInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<BillInfo>> getAllBills() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<BillInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/bills',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => BillInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<BillInfo>> getBillsByOrder(orderId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<BillInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/bills/order/${orderId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => BillInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<BillInfo> getBillById(billId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<BillInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/bills/${billId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = BillInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> updateBillStatus(billId, statusOrder) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'statusOrder': statusOrder};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'PUT', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/bills/${billId}/status',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<ProductInfo>> getAllProducts() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => ProductInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<ProductInfo> getProductById(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ProductInfo> createProduct(product) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(product.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ProductInfo> updateProduct(id, product) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(product.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductInfo>(
        Options(method: 'PUT', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteProduct(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<ProductVariant>> getVariantsByProductId(fkVariantProduct) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductVariant>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_variant/${fkVariantProduct}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map(
              (dynamic i) => ProductVariant.fromJson(i as Map<String, dynamic>),
            )
            .toList();
    return value;
  }

  @override
  Future<ProductVariant> createProductVariant(variant) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(variant.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductVariant>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_variant',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductVariant.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ProductVariant> updateProductVariant(id, variant) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(variant.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductVariant>(
        Options(method: 'PUT', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_variant/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductVariant.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteProductVariant(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_variant/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<ProductColor>> getColorsByVariantId(fkVariantProduct) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductColor>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_color/${fkVariantProduct}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map(
              (dynamic i) => ProductColor.fromJson(i as Map<String, dynamic>),
            )
            .toList();
    return value;
  }

  @override
  Future<ProductColor> createProductColor(color) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(color.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductColor>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_color',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductColor.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ProductColor> updateProductColor(id, color) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(color.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductColor>(
        Options(method: 'PUT', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_color/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductColor.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteProductColor(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_color/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<ProductImage>> getImagesByProduct(fkImageProduct) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductImage>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_images/${fkImageProduct}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map(
              (dynamic i) => ProductImage.fromJson(i as Map<String, dynamic>),
            )
            .toList();
    return value;
  }

  @override
  Future<ProductImage> createProductImage(image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(image.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ProductImage>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_images',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ProductImage.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteProductImage(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_images/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<void> deleteImagesByFkImageProduct(fkImageProduct) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/products/product_images/fk/${fkImageProduct}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
