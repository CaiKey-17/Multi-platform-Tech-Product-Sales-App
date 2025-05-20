// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ApiService implements ApiService {
  _ApiService(this._dio, {this.baseUrl}) {
    baseUrl ??= ApiConfig.baseUrlAPI;
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<LoginResponse> login(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<LoginResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/login',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = LoginResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<dynamic>> changePassword(
    token,
    oldPassword,
    newPassword,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'oldPassword': oldPassword,
      r'newPassword': newPassword,
    };
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse<dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/changePassword',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<RegisterResponse> register(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<RegisterResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/register',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = RegisterResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ValidResponse> verifyOtp(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ValidResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/verify-otp',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ValidResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ResendOtpResponse> resendOtp(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ResendOtpResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/resend-otp',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ResendOtpResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UserInfo> getUserInfo(token) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<UserInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/user-info',
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
  Future<AdminInfo> getAdminInfo(token) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<AdminInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/admin-info',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = AdminInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> changeImage(token, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/user-info/change',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<void> changeName(token, name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/user-info/update-name',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<AddressList>> getListAddress(token) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<AddressList>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/address',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => AddressList.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<AddressResponse> addAddress(address) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(address.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<AddressResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/address/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = AddressResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> chooseAddressDefault(token, addressId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'addressId': addressId};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/address/default',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<CategoryInfo>> getListCategory() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CategoryInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/category/list',
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
  Future<List<CategoryInfo>> getListBrand() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CategoryInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/brand/list',
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
  Future<List<ProductInfo>> getProductsPromotion() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/promotion',
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
  Future<List<ProductInfo>> getProductsNew() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/new',
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
  Future<List<ProductInfo>> getProductsBestSeller() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/best-seller',
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
  Future<List<ProductInfo>> getProductsLaptop() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/laptop',
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
  Future<List<ProductInfo>> getProductsPhone() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/phone',
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
  Future<List<ProductInfo>> getProductsPc() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/pc',
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
  Future<List<ProductInfo>> getProductsKeyBoard() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/keyboard',
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
  Future<List<ProductInfo>> getProductsMonitor() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/monitor',
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
  Future<List<ProductInfo>> getProductsByCategory(fk_category) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fk_category': fk_category};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/category',
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
  Future<List<ProductInfo>> getProductsBySearch(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/search',
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
  Future<List<ProductInfo>> getProductsBySearchAdvance(
    name,
    brand,
    minPrice,
    maxPrice,
    rating,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'name': name,
      r'brand': brand,
      r'minPrice': minPrice,
      r'maxPrice': maxPrice,
      r'rating': rating,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/search-advance',
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
  Future<Product> getProductDetail(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': id};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Product>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/detail',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = Product.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<Comment>> getCommentInProduct(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': id};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<Comment>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/comments',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => Comment.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<Comment> postComment(comment) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(comment.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Comment>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/comments',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = Comment.fromJson(_result.data!);
    return value;
  }

  @override
  Future<Comment> replyToComment(commentId, reply) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(reply.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Comment>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/comments/${commentId}/reply',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = Comment.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<ProductInfo>> getProductsByBrand(fk_brand) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fk_brand': fk_brand};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/brand',
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
  Future<List<RatingInfo>> getRatingsByProduct(productId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'productId': productId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<RatingInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/rating/product',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => RatingInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<RatingInfo> createRating(productId, rating) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(rating.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<RatingInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/rating/product/${productId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = RatingInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<CartInfo>> getItemInCart({token, id}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': id};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CartInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => CartInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<CartInfo>> getItemInCartDetail({orderId}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'orderId': orderId};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CartInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/list-detail',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => CartInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<Map<String, dynamic>> getRawQuantityInCart(userId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'userId': userId};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/quantity',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<void> sendResetPassword(email) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'email': email};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/forgot-password',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<Coupon> findCoupon(name, price) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name, r'price': price};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Coupon>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/coupon/find',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = Coupon.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CouponAdmin> listCoupon() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<CouponAdmin>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/coupon',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = CouponAdmin.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> addCoupon(couponValue, maxAllowedUses, minOrderValue) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'couponValue': couponValue,
      r'maxAllowedUses': maxAllowedUses,
      r'minOrderValue': minOrderValue,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/coupon',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<void> deleteCoupon(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': id};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/coupon/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> addToCart(
    token,
    productId,
    colorId,
    quantity,
    id,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'productId': productId,
      r'colorId': colorId,
      r'quantity': quantity,
      r'id': id,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<Map<String, dynamic>> minusToCart(productId, orderId, colorId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'productId': productId,
      r'orderId': orderId,
      r'colorId': colorId,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/minus',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<Map<String, dynamic>> deleteToCart(orderDetailId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'orderDetailId': orderDetailId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<List<Map<String, dynamic>>> findPendingOrdersByCustomer(token) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<Map<String, dynamic>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/pending',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => Map<String, dynamic>.from(i as Map))
            .toList();

    return value;
  }

  @override
  Future<List<Map<String, dynamic>>> findDeliveringOrdersByCustomer(
    token,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<Map<String, dynamic>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/delivering',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => Map<String, dynamic>.from(i as Map))
            .toList();

    return value;
  }

  @override
  Future<List<Map<String, dynamic>>> findDeliveredOrdersByCustomer(
    token,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<Map<String, dynamic>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/delivered',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => Map<String, dynamic>.from(i as Map))
            .toList();

    return value;
  }

  @override
  Future<Map<String, dynamic>> confirmToCart(
    orderId,
    address,
    couponTotal,
    email,
    fkCouponId,
    pointTotal,
    priceTotal,
    ship,
    tempId,
    id,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'orderId': orderId,
      r'address': address,
      r'couponTotal': couponTotal,
      r'email': email,
      r'fkCouponId': fkCouponId,
      r'pointTotal': pointTotal,
      r'priceTotal': priceTotal,
      r'ship': ship,
      r'tempId': tempId,
      r'id': id,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/confirm',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<dynamic>> cancelToCart(orderId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'orderId': orderId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse<dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/cancel',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<dynamic>> acceptToCart(orderId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'orderId': orderId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse<dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/accept',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<dynamic>> received(orderId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'orderId': orderId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse<dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/order/received',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getUserStatistics() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse<Map<String, dynamic>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/user-stats',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse<Map<String, dynamic>>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getOrderStatistics() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse<Map<String, dynamic>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/order-stats',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse<Map<String, dynamic>>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse1<List<Map<String, dynamic>>>>
  getTopSellingProducts() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<Map<String, dynamic>>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/top-selling-products',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<Map<String, dynamic>>>.fromJson(
      _result.data!,
      (data) => (data as List).cast<Map<String, dynamic>>(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceData(
    period,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'period': period};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<PerformanceDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/performance',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<PerformanceDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => PerformanceDataDTO.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceDataByYear(
    year,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'year': year};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<PerformanceDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/performance-year',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<PerformanceDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => PerformanceDataDTO.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<PerformanceDataDTO>>>
  getPerformanceDataByYearQuarter(year, quarter) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'year': year,
      r'quarter': quarter,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<PerformanceDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/performance-year-quarter',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<PerformanceDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => PerformanceDataDTO.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceDataByYearMonth(
    year,
    month,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'year': year, r'month': month};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<PerformanceDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/performance-year-month',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<PerformanceDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => PerformanceDataDTO.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<PerformanceDataDTO>>> getPerformanceDataByYearWeek(
    year,
    month,
    week,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'year': year,
      r'month': month,
      r'week': week,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<PerformanceDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/performance-year-week',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<PerformanceDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => PerformanceDataDTO.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<ProductDataDTO>>> getProductData(period) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'period': period};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<ProductDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/product-stats',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<ProductDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List).map((item) => ProductDataDTO.fromJson(item)).toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<PerformanceDataDTO>>> getCustomPerformanceData(
    start,
    end,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'start': start, r'end': end};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<PerformanceDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/performance/custom',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<PerformanceDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => PerformanceDataDTO.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<ProductDataDTO>>> getCustomProductData(
    start,
    end,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'start': start, r'end': end};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<ProductDataDTO>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/product-stats/custom',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<ProductDataDTO>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List).map((item) => ProductDataDTO.fromJson(item)).toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYear() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-products-by-year',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<TotalProductByYear>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => TotalProductByYear.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearMonth(
    year,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'year': year};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-products-by-year-month',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<TotalProductByYear>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => TotalProductByYear.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearMonthV2(
    year,
    month,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'year': year, r'month': month};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-products-by-year-month-v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<TotalProductByYear>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => TotalProductByYear.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearQuarter(
    year,
    quarter,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'year': year,
      r'quarter': quarter,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-products-by-year-quarter',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<TotalProductByYear>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => TotalProductByYear.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<TotalProductByYear>>> getSoldProductsByYearMonthWeek(
    year,
    month,
    week,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'year': year,
      r'month': month,
      r'week': week,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-products-by-year-month-week',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<TotalProductByYear>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => TotalProductByYear.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<TotalProductByYear>>> getTotalProductByDayBetween(
    start,
    end,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'start': start, r'end': end};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-products/custom',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<TotalProductByYear>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => TotalProductByYear.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYear() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<CategorySalesProjection>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-type-products-by-year',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<CategorySalesProjection>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => CategorySalesProjection.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearMonth(year) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'year': year};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-type-products-by-year-month',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<CategorySalesProjection>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => CategorySalesProjection.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearMonthV2(year, month) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'year': year, r'month': month};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-type-products-by-year-month-v2',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<CategorySalesProjection>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => CategorySalesProjection.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearQuarter(year, quarter) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'year': year,
      r'quarter': quarter,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-type-products-by-year-quarter',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<CategorySalesProjection>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => CategorySalesProjection.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getSoldTypeProductsByYearMonthWeek(year, month, week) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'year': year,
      r'month': month,
      r'week': week,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<CategorySalesProjection>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-type-products-by-year-month-week',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<CategorySalesProjection>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => CategorySalesProjection.fromJson(item))
              .toList(),
    );
    return value;
  }

  @override
  Future<ApiResponse1<List<CategorySalesProjection>>>
  getTotalTypeProductByDayBetween(start, end) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'start': start, r'end': end};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ApiResponse1<List<TotalProductByYear>>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/statistic/sold-type-products/custom',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ApiResponse1<List<CategorySalesProjection>>.fromJson(
      _result.data!, // _result.data là Map<String, dynamic>
      (data) =>
          (data as List)
              .map((item) => CategorySalesProjection.fromJson(item))
              .toList(),
    );
    return value;
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
