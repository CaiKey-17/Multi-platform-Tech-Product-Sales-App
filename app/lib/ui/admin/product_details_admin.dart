import 'dart:convert';
import 'dart:math';

import 'package:app/globals/convert_money.dart';
import 'package:app/globals/ip.dart';
import 'package:app/models/cart_info.dart';
import 'package:app/models/color_model.dart';
import 'package:app/models/comment.dart';
import 'package:app/models/comment_info.dart';
import 'package:app/models/comment_reply_request.dart';
import 'package:app/models/comment_request.dart';
import 'package:app/models/image_model.dart';
import 'package:app/models/product_info.dart';
import 'package:app/models/product_info_detail.dart';
import 'package:app/models/rating_info.dart';
import 'package:app/models/sentiment_request.dart';
import 'package:app/models/sentiment_response.dart';
import 'package:app/models/variant_model.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/repositories/cart_repository.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/api_service_sentiment.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/product/main_brand.dart';
import 'package:app/ui/product/main_category.dart';
import 'package:app/ui/main_page.dart';
import 'package:app/ui/order/payment_process.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:provider/provider.dart';

class ProductAdminPage extends StatefulWidget {
  final int productId;

  const ProductAdminPage({super.key, required this.productId});

  @override
  _ProductAdminPageState createState() => _ProductAdminPageState();
}

class _ProductAdminPageState extends State<ProductAdminPage> {
  late ApiService apiService;
  late StompClient stompClient;

  int selectedColorIndex = 0;
  int selectedVersionIndex = 0;
  int id_Color = -1;
  int id_Variant = -1;
  String name = "";
  String fullName = "";
  double? price;
  double priceO = 0.0;
  int _currentIndex = 0;
  List<String> images = [];
  List<ColorOption> colors = [];
  List<Variant> versions = [];
  List<RatingInfo> ratings = [];
  List<Map<String, dynamic>> reviews = [];
  bool hasReviewed = false;
  List<Comment> commentsN = [];
  List<Map<String, dynamic>> comments = [];

  Future<void> fetchCommentByProduct(int productId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getCommentInProduct(productId);
      setState(() {
        commentsN = response;
        print(commentsN.length);
        comments =
            commentsN.map((commentInfo) => commentInfo.toJson()).toList();

        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  int displayedCommentCount = 5;
  final TextEditingController _newCommentController = TextEditingController();

  bool isLoading = true;
  Product? product;
  List<CartInfo> cartItems = [];
  int? userId;
  int orderId = -1;
  String role = "";

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());

    cartRepository = CartRepository(apiService);
    cartService = CartService(cartRepository: cartRepository);
    _loadUserData();
    fetchProductDetail();

    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: ApiConfig.baseUrlWsc,
        onConnect: onConnectCallback,
        onWebSocketError: (dynamic error) => print("WebSocket Error: $error"),
      ),
    );

    stompClient.activate();
  }

  void onConnectCallback(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/ratings/${widget.productId}',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final data = json.decode(frame.body!);
          print("Rating mới: $data");
          setState(() {
            reviews.insert(0, {
              'id': data['id'],
              'name': data['name'],
              'rating': data['rating'],
              'content': data['content'],
              'verified': (data['sentiment'] == 1 || data['sentiment'] == 2),
              'goodCount': (data['sentiment'] == 1) ? 1 : 0,
              'badCount': (data['sentiment'] == 0) ? 1 : 0,
              'liked': (data['sentiment'] == 1),
              'disliked': (data['sentiment'] == 0),
              'idFkCustomer': data['idFkCustomer'],
            });
          });
        }
      },
    );
  }

  Future<void> handleAddToCart() async {
    setState(() {
      isLoading = true;
    });

    final success = await cartService.addToCart(
      productID: id_Variant,
      colorId: id_Color,
      id: widget.productId,
      token: token,
      context: context,
    );

    if (success == true) {
      await Future.delayed(Duration(milliseconds: 500));
      await fetchCartItems();
    } else {
      setState(() {
        isLoading = false;
      });
      print("Thêm vào giỏ hàng thất bại");
    }
  }

  Future<void> fetchCartItems() async {
    try {
      List<CartInfo> response;
      if (token.isNotEmpty && userId == -1) {
        response = await apiService.getItemInCart(token: token);
        print("Sử dụng token");
      } else if (token == "" && userId != -1) {
        response = await apiService.getItemInCart(id: userId);
        print("Sử dụng userID");
      } else {
        response = await apiService.getItemInCart(token: token, id: userId);
        print("Sử dụng cả 2");
      }
      setState(() {
        cartItems = response;
        orderId = cartItems.isNotEmpty ? cartItems[0].orderId : -1;
        isLoading = false;
      });
      if (orderId == -1) {
        print("orderId chưa hợp lệ");
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentConfirmationScreen(
                orderId: orderId,
                cartItems: cartItems,
              ),
        ),
      );
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      userId = prefs.getInt('userId') ?? -1;
      fullName = prefs.getString('fullName') ?? "";
      role = prefs.getString('role') ?? "ROLE_CUSTOMER";
      Future.microtask(() {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.fetchCartFromApi(userId);
      });
    });
  }

  Future<void> fetchProductDetail() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductDetail(widget.productId);
      setState(() {
        product = response;
        for (ProductImage i in product!.images) {
          images.add(i.image);
        }
        versions = product!.variants;
        if (versions.isNotEmpty) {
          selectedVersionIndex = 0;
          name = versions[0].name;
          priceO = versions[0].oldPrice;
          colors = versions[0].colors;
          id_Variant = versions[0].id;
          if (colors.isNotEmpty) {
            selectedColorIndex = 0;
            price = colors[0].price;
            id_Color = colors[0].id;
            for (ColorOption i in colors) {
              images.add(i.image);
            }
          } else {
            selectedColorIndex = -1;
            price = versions[0].price;
            priceO = versions[0].oldPrice;
          }
        }
        fetchProductsBrand(product!.brand);
        fetchProductsCategory(product!.category);
        fetchRatingsByProduct(widget.productId);
        fetchCommentByProduct(widget.productId);

        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsBrand(String brand) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsByBrand(brand);
      setState(() {
        for (ProductInfo i in response) {
          if (i.id != widget.productId) {
            products_brand.add(i);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRatingsByProduct(int producId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getRatingsByProduct(producId);
      setState(() {
        ratings = response;
        reviews =
            ratings.map((rating) {
              final isVerified =
                  (rating.sentiment == 1 || rating.sentiment == 2);
              final goodCount = (rating.sentiment == 1) ? 1 : 0;
              bool like = (rating.sentiment == 1) ? true : false;

              final badCount = (rating.sentiment == 0) ? 1 : 0;
              bool dislike = (rating.sentiment == 0) ? true : false;
              print(rating.sentiment);
              return {
                'id': rating.id,
                'name': rating.name,
                'rating': rating.rating,
                'content': rating.content,
                'verified': isVerified,
                'goodCount': goodCount,
                'badCount': badCount,
                'liked': like,
                'disliked': dislike,
                'idFkCustomer': rating.idFkCustomer,
              };
            }).toList();

        hasReviewed = reviews.any((review) => review['idFkCustomer'] == userId);

        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsCategory(String category) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsByCategory(category);
      setState(() {
        for (ProductInfo i in response) {
          if (i.id != widget.productId) {
            products_category.add(i);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        foregroundColor: Colors.white,

        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(
          child: Text(
            "Thông tin chi tiết",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoppingCartPage(isFromTab: false),
                  ),
                );
              },
              child: badges.Badge(
                showBadge: cartProvider.cartItemCount > 0,
                badgeContent: Text(
                  cartProvider.cartItemCount.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.redAccent,
                  elevation: 0,
                ),
                position: badges.BadgePosition.topEnd(top: -6, end: -6),
                child: Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
              : Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                              itemCount: images.length,
                              itemBuilder: (context, index, realIndex) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(images[index]),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 250,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                viewportFraction: 1.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '${_currentIndex + 1}/${images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thương hiệu: ${product?.brand}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (index) {
                                        if (index < product!.rating.floor()) {
                                          return const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        } else if (index < product!.rating &&
                                            (product!.rating - index) >= 0.5) {
                                          return const Icon(
                                            Icons.star_half,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        } else {
                                          return const Icon(
                                            Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        }
                                      }),
                                    ),

                                    const SizedBox(width: 4),
                                    Text(
                                      '( ${reviews.length} đánh giá )',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(versions.length, (
                                    index,
                                  ) {
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedVersionIndex = index;
                                            name = versions[index].name;
                                            priceO = versions[index].oldPrice;

                                            colors = versions[index].colors;
                                            id_Variant = versions[index].id;
                                            if (colors.isNotEmpty) {
                                              selectedColorIndex = 0;
                                              price = colors[0].price;
                                              id_Color = colors[0].id;
                                            } else {
                                              selectedColorIndex = -1;
                                              price = versions[index].price;
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  selectedVersionIndex == index
                                                      ? Colors.blue
                                                      : Colors.grey,
                                              width:
                                                  selectedVersionIndex == index
                                                      ? 2
                                                      : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                versions[index].name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Chọn màu:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(colors.length, (
                                    index,
                                  ) {
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (colors.isNotEmpty) {
                                            setState(() {
                                              selectedColorIndex = index;
                                              price = colors[index].price;
                                              id_Color = colors[index].id;
                                            });
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  selectedColorIndex == index
                                                      ? Colors.blue
                                                      : Colors.grey,
                                              width:
                                                  selectedColorIndex == index
                                                      ? 2
                                                      : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                colors[index].nameColor,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${ConvertMoney.currencyFormatter.format(colors[index].price)} ₫",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 60,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${ConvertMoney.currencyFormatter.format(price)} ₫",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            16,
                                            118,
                                            201,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${ConvertMoney.currencyFormatter.format(priceO)} ₫",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Thông tin chi tiết',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SpecificationWidget(
                                      detail: product!.detail,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Mô tả sản phẩm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DescriptionWidget(
                                      description: product!.description,
                                    ),

                                    const SizedBox(height: 10),
                                    ProductRatingWidget(
                                      productName: product!.name,
                                      productId: product!.id,
                                      reviews: reviews,
                                      images: images,
                                      onViewMoreReviews: () {
                                        setState(() {});
                                      },
                                      onWriteReview:
                                          () => print('Viết đánh giá'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Hỏi và đáp',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                CommentSectionWidget(
                                  role: role != null ? role : 'ROLE_CUSTOMER',
                                  productId: widget.productId,
                                  fullName:
                                      fullName != null
                                          ? fullName
                                          : 'Người dùng vô danh',
                                  comments: comments,
                                  initialCommentCount: 5,
                                  controller: _newCommentController,
                                  onSend: () async {
                                    if (_newCommentController.text.isNotEmpty) {
                                      final replyRequest = CommentRequest(
                                        username:
                                            fullName != ""
                                                ? fullName
                                                : "Người dùng ẩn danh",
                                        content: _newCommentController.text,
                                        productId: widget.productId,
                                        role:
                                            role != "" ? role : 'ROLE_CUSTOMER',
                                      );

                                      try {
                                        final newReply = await apiService
                                            .postComment(replyRequest);
                                        setState(() {
                                          _newCommentController.clear();
                                        });
                                      } catch (e) {
                                        print('Lỗi khi gửi phản hồi: $e');
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
    );
  }
}

class SpecificationWidget extends StatefulWidget {
  final String? detail;
  const SpecificationWidget({super.key, this.detail});

  @override
  State<SpecificationWidget> createState() => _SpecificationWidgetState();
}

class _SpecificationWidgetState extends State<SpecificationWidget> {
  // final String sampleSpecString =
  //     "Title: Thông số kỹ thuật; CPU: Snapdragon 8 Gen 2; RAM: 16GB; Title: Màn hình; Kích thước: 6.8 inch; Độ phân giải: 1440 x 3200 pixels; Title: Camera; Camera chính: 50MP; Camera trước: 32MP, ; Siêu đẹp: 32MP";

  List<Map<String, String>> _parseSpecifications(String specString) {
    if (specString.isEmpty) return [];

    List<Map<String, String>> specs = [];
    List<String> items = specString.split("; ");

    for (String item in items) {
      if (item.startsWith("Title: ")) {
        specs.add({"title": item.substring(7)});
      } else {
        List<String> keyValue = item.split(": ");
        if (keyValue.length == 2) {
          specs.add({keyValue[0]: keyValue[1]});
        }
      }
    }
    return specs;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> specifications = _parseSpecifications(
      widget.detail!,
    );

    List<Map<String, String>> filteredSpecs =
        specifications
            .where((spec) => !spec.keys.first.toLowerCase().contains("title"))
            .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...filteredSpecs.take(5).map((spec) {
                String key = spec.keys.first;
                String value = spec.values.first;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.95,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.95,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Thông số chi tiết",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: specifications.length,
                                    itemBuilder: (context, index) {
                                      Map<String, String> spec =
                                          specifications[index];
                                      String key = spec.keys.first;
                                      String value = spec.values.first;
                                      bool isTitle = key.toLowerCase().contains(
                                        "title",
                                      );

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child:
                                            isTitle
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 10,
                                                        bottom: 5,
                                                      ),
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                                : Container(
                                                  color:
                                                      index % 2 == 0
                                                          ? Colors.grey[100]
                                                          : Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 8,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          key,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Xem thêm",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// const String productDescription =
//     "Bạn đang cần tìm màn hình hiển thị sắc nét, hiệu năng vượt trội với mức giá hợp lý? "
//     "Màn hình MSI PRO MP242L với kích thước 24 inch (23.8 inch) chính là sự lựa chọn hoàn hảo đến từ thương hiệu uy tín. "
//     "Được trang bị độ phân giải Full HD, tấm nền IPS cao cấp và tần số quét 100Hz, thiết bị không chỉ mang lại trải nghiệm hình ảnh sống động "
//     "mà còn hỗ trợ bảo vệ thị lực tối ưu cho người dùng. Hãy cùng khám phá các thông tin nổi bật của loại màn hình này nhé!\n\n"
//     "Màn hình MSI PRO MP242L 23.8 inch nổi bật với thiết kế thanh lịch và kích thước (không chân) 542 x 28 x 321 mm, khối lượng 2kg và kích thước "
//     "(có chân) 542 x 174 x 391 mm, khối lượng 3.5kg dễ dàng phù hợp với mọi không gian sử dụng văn phòng. Với viền mỏng 3 cạnh hiện đại, tỷ lệ khung hình 16:9 "
//     "không chỉ tối ưu không gian hiển thị mà còn mang lại vẻ đẹp tinh tế, nâng tầm thẩm mỹ cho góc làm việc hay giải trí. Phần mặt sau được tô điểm bởi các họa tiết "
//     "tạo điểm nhấn độc đáo và đầy cảm hứng. Thiết kế tối giản này tạo điều kiện thuận lợi khi thiết lập đa màn hình, đáp ứng linh hoạt nhu cầu sử dụng.";

class DescriptionWidget extends StatefulWidget {
  final String? description;

  const DescriptionWidget({super.key, this.description});

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  @override
  Widget build(BuildContext context) {
    bool isLongText = widget.description!.length > 200;
    String shortDescription =
        isLongText
            ? "${widget.description!.substring(0, 400)}..."
            : widget.description!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(shortDescription, style: const TextStyle(fontSize: 14)),
              if (isLongText)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.95,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.9,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Chi tiết mô tả",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      widget.description!,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Center(
                    child: Text(
                      "Xem thêm",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (isLongText)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.7),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductRatingWidget extends StatefulWidget {
  final String productName;
  final int productId;
  List<Map<String, dynamic>> reviews;
  final List<String> images;
  final VoidCallback? onViewMoreReviews;
  final VoidCallback? onWriteReview;

  ProductRatingWidget({
    super.key,
    required this.productName,
    required this.productId,
    required this.reviews,
    required this.images,
    this.onViewMoreReviews,
    this.onWriteReview,
  });

  @override
  _ProductRatingWidgetState createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends State<ProductRatingWidget> {
  late ApiService apiService;
  late ApiServiceSentiment apiServiceSentiment;
  List<RatingInfo> ratings = [];
  String fullName = "Người dùng vô danh";
  int userId = -1;

  String? sentiment;
  bool isLoading = true;
  bool showAllReviews = false;
  int selectedRating = 0;
  bool hasReviewed = false;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      fullName = prefs.getString('fullName') ?? "Người dùng vô danh";
      userId = prefs.getInt('userId') ?? -1;
      isLoading = false;
    });
  }

  Future<void> fetchRatingsByProduct() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await apiService.getRatingsByProduct(widget.productId);
      setState(() {
        ratings = response;
        widget.reviews =
            ratings.map((rating) {
              final isVerified =
                  (rating.sentiment == 1 || rating.sentiment == 2);
              final goodCount = (rating.sentiment == 1) ? 1 : 0;
              bool like = (rating.sentiment == 1) ? true : false;

              final badCount = (rating.sentiment == 0) ? 1 : 0;
              bool dislike = (rating.sentiment == 0) ? true : false;

              return {
                'id': rating.id,
                'name': rating.name,
                'rating': rating.rating,
                'content': rating.content,
                'verified': isVerified,
                'goodCount': goodCount,
                'badCount': badCount,
                'liked': like,
                'disliked': dislike,
                'idFkCustomer': rating.idFkCustomer,
              };
            }).toList();
        hasReviewed = widget.reviews.any(
          (review) => review['idFkCustomer'] == userId,
        );

        print(hasReviewed);
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSentiment(int rating, String text) async {
    try {
      final request = SentimentRequest(text: text);
      final response = await apiServiceSentiment.getSentiment(request);
      setState(() {
        isLoading = true;
        hasReviewed = true;
      });

      setState(() {
        sentiment = response.result;
        print("ok");
        print(sentiment);
      });
      int sentimentValue;
      if (sentiment == 'Positive') {
        sentimentValue = 1;
      } else if (sentiment == 'Negative') {
        sentimentValue = 0;
      } else {
        sentimentValue = 3;
      }
      final rating_info = RatingInfo.noId(
        name: fullName,
        rating: rating,
        content: text,
        sentiment: sentimentValue,
        idFkCustomer: userId,
        idFkProduct: widget.productId,
      );

      final response_rating = await apiService.createRating(
        widget.productId,
        rating_info,
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apiServiceSentiment = ApiServiceSentiment(Dio());
    apiService = ApiService(Dio());

    _loadUserData();

    fetchRatingsByProduct();
    for (var review in widget.reviews) {
      review['liked'] = false;
      review['disliked'] = false;
    }
  }

  void updateReview(int index, Map<String, dynamic> updatedReview) {
    setState(() {
      widget.reviews[index] = updatedReview;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedReviews =
        showAllReviews ? widget.reviews : widget.reviews.take(3).toList();
    double averageRating =
        widget.reviews.isEmpty
            ? 0
            : widget.reviews
                    .map((r) => r['rating'] as int)
                    .reduce((a, b) => a + b) /
                widget.reviews.length;
    int totalReviews = widget.reviews.length;
    int goodCount = widget.reviews.fold(
      0,
      (sum, r) => sum + (r['goodCount'] as int),
    );
    int badCount = widget.reviews.fold(
      0,
      (sum, r) => sum + (r['badCount'] as int),
    );
    String satisfactionText =
        averageRating >= 4
            ? 'Rất tốt'
            : (averageRating >= 3 ? 'Tốt' : 'Trung bình');
    Map<int, double> ratingPercentages = {
      5: 0.7,
      4: 0.2,
      3: 0.05,
      2: 0.03,
      1: 0.02,
    };

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá sản phẩm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const Text('/5', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          Text(
                            '$satisfactionText ',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '( $totalReviews đánh giá )',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tốt: $goodCount',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Không tốt: $badCount',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(5, (index) {
                            int star = 5 - index;
                            double percentage = ratingPercentages[star] ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      '$star',
                                      style: const TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    size: 15,
                                    color: Colors.amber,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Colors.blue,
                                            ),
                                        minHeight: 10,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${(percentage * 100).round()}%',
                                      style: const TextStyle(fontSize: 14),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1),

                  Stack(
                    children: [
                      Column(
                        children:
                            displayedReviews.map((review) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                review['name'] + " ",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (review['verified'] as bool)
                                                const Icon(
                                                  Icons.verified,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                i < (review['rating'] as int)
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          Text(review['content'] as String),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.sentiment_satisfied_alt,
                                            color:
                                                review['liked']
                                                    ? Colors.green
                                                    : Colors.grey,
                                          ),
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            Icons
                                                .sentiment_dissatisfied_outlined,
                                            color:
                                                review['disliked']
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                      if (widget.reviews.length > 3 && !showAllReviews)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.7),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AllReviewsDialog(
                                    reviews: widget.reviews,
                                    onUpdateReview: updateReview,
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),

                          child: const Text(
                            'Xem đánh giá',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (token != null &&
                          token.isNotEmpty &&
                          hasReviewed == false)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => ReviewDialog(
                                      productName: widget.productName,
                                      images: widget.images,
                                      onSubmit: (rating, comment) {
                                        setState(() {
                                          fetchSentiment(rating, comment);
                                        });
                                      },
                                    ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Viết đánh giá'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
    );
  }
}

class AllReviewsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;

  final Function(int, Map<String, dynamic>) onUpdateReview;

  const AllReviewsDialog({
    super.key,
    required this.reviews,
    required this.onUpdateReview,
  });

  @override
  _AllReviewsDialogState createState() => _AllReviewsDialogState();
}

class _AllReviewsDialogState extends State<AllReviewsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tất cả đánh giá",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children:
                      widget.reviews.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> review = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          review['name'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (review['verified'] as bool)
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < (review['rating'] as int)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    Text(review['content'] as String),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.sentiment_satisfied_alt,
                                      color:
                                          review['liked']
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.sentiment_dissatisfied_outlined,
                                      color:
                                          review['disliked']
                                              ? Colors.red
                                              : Colors.grey,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final String productName;
  final List<String> images;
  final Function(int rating, String comment) onSubmit;

  const ReviewDialog({
    super.key,
    required this.productName,
    required this.images,
    required this.onSubmit,
  });

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              widget.images.isNotEmpty
                  ? widget.images[0]
                  : 'https://via.placeholder.com/150',
              width: 200,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            if (selectedRating > 0)
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Nhập đánh giá của bạn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                maxLines: 3,
              ),

            const SizedBox(height: 10),
            if (selectedRating > 0)
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    widget.onSubmit(selectedRating, _commentController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Gửi đánh giá'),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFilterButton(String text) {
  return ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(text),
  );
}

Widget _buildStarRating(int stars) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(width: 1, color: Colors.grey),
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    child: Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Icon(Icons.star, color: Colors.yellow[700], size: 15),
      ],
    ),
  );
}

List<ProductInfo> products_brand = [];
List<ProductInfo> products_category = [];
late CartRepository cartRepository;
late CartService cartService;
String token = "";
int? userId;

Widget _buildListView(List<ProductInfo> products) {
  return Container(
    height: 400,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final int rating = Random().nextInt(3) + 3;

        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.network(
                        product.image,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${ConvertMoney.currencyFormatter.format(product.price)} ₫",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${ConvertMoney.currencyFormatter.format(product.oldPrice)} ₫",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "-" + product.discountPercent.toString() + "%",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      cartService.addToCart(
                        productID: product.idVariant,
                        colorId: product.idColor,
                        id: product.id,
                        token: token,
                        context: context,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue, width: 1),
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Thêm giỏ hàng",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildTitle(String title, VoidCallback onViewMore) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      GestureDetector(
        onTap: onViewMore,
        child: const Text(
          "Xem thêm",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
          ),
        ),
      ),
    ],
  );
}

class CommentSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> comments;
  final int initialCommentCount;
  final String fullName;
  final int productId;
  final String role;
  final TextEditingController controller;
  final VoidCallback onSend;

  const CommentSectionWidget({
    super.key,
    required this.comments,
    required this.role,
    required this.initialCommentCount,
    required this.controller,
    required this.onSend,
    required this.productId,
    required this.fullName,
  });

  @override
  _CommentSectionWidgetState createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  late StompClient stompClient;
  late int displayedCommentCount;
  int? replyingToIndex;
  final TextEditingController _replyController = TextEditingController();
  late ApiService apiService;
  final Map<int, StompUnsubscribe> replySubscriptions = {};

  void connectToWebSocket() {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: ApiConfig.baseUrlWsc,
        onConnect: onStompConnected,
        onWebSocketError: (dynamic error) => print('Lỗi WS: $error'),
      ),
    );

    stompClient.activate();
  }

  void onStompConnected(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/comments/${widget.productId}',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          setState(() {
            widget.comments.insert(0, data);

            subscribeToReplies(data['id']);
          });
        }
      },
    );

    for (var comment in widget.comments) {
      if (comment['id'] != null) {
        subscribeToReplies(comment['id']);
      }
    }
  }

  void subscribeToReplies(int commentId) {
    if (replySubscriptions.containsKey(commentId)) return;

    final subscription = stompClient.subscribe(
      destination: '/topic/replies/$commentId',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          setState(() {
            final index = widget.comments.indexWhere(
              (c) => c['id'] == commentId,
            );
            if (index != -1) {
              widget.comments[index]['replies'] ??= [];
              widget.comments[index]['replies'].add(data);
            }
          });
        }
      },
    );

    replySubscriptions[commentId] = subscription;
  }

  @override
  void initState() {
    super.initState();

    apiService = ApiService(Dio());
    connectToWebSocket();
    displayedCommentCount = widget.initialCommentCount;
  }

  @override
  void dispose() {
    for (final sub in replySubscriptions.values) {
      sub();
    }
    stompClient.deactivate();
    super.dispose();
  }

  void toggleComments() {
    setState(() {
      if (displayedCommentCount < widget.comments.length) {
        displayedCommentCount = (displayedCommentCount + 5).clamp(
          0,
          widget.comments.length,
        );
      } else {
        displayedCommentCount = widget.initialCommentCount;
      }
    });
  }

  void onReply(int index, int commentId) {
    setState(() {
      if (replyingToIndex == index) {
        replyingToIndex = null;
      } else {
        replyingToIndex = index;
      }
    });
  }

  void onSendReply(int index, int commentId, String role) async {
    final replyRequest = CommentReplyRequest(
      username: widget.fullName != "" ? widget.fullName : "Người dùng ẩn danh",
      content: _replyController.text,
      commentId: commentId,
      role: role != "" ? role : "ROLE_CUSTOMER",
    );

    try {
      final newReply = await apiService.replyToComment(commentId, replyRequest);
      setState(() {
        _replyController.clear();
        replyingToIndex = null;
      });
    } catch (e) {
      print('Lỗi khi gửi phản hồi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedComments =
        widget.comments.take(displayedCommentCount).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Nhập bình luận của bạn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  children: [
                    Text('Gửi', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 4),
                    Icon(Icons.send, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children:
                displayedComments.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> comment = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  comment['role'] == "ROLE_ADMIN"
                                      ? Colors.red[100]
                                      : Colors.grey[300],
                              child: Text(
                                comment['username'][0].toString().toUpperCase(),
                                style: TextStyle(
                                  color:
                                      comment['role'] == "ROLE_ADMIN"
                                          ? Colors.red
                                          : Colors.black,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['username'] != ""
                                            ? comment['username']
                                            : 'Người dùng ẩn danh',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (comment['role'] == "ROLE_ADMIN")
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'qtv',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    comment['content'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${comment['daysAgo']} ngày trước',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onReply(index, comment['id']),
                              child: Text(
                                'Trả lời',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (comment['replies'] != null &&
                            comment['replies'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 40.0,
                              top: 8.0,
                            ),
                            child: Column(
                              children:
                                  (comment['replies'] as List).map((reply) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                reply['role'] == "ROLE_ADMIN"
                                                    ? Colors.red[100]
                                                    : Colors.grey[300],
                                            child: Text(
                                              reply['username'][0]
                                                  .toString()
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color:
                                                    reply['role'] ==
                                                            "ROLE_ADMIN"
                                                        ? Colors.red
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      reply['username'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    if (reply['role'] ==
                                                        "ROLE_ADMIN")
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red[50],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          'qtv',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Text(
                                                  reply['content'],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${reply['daysAgo']} ngày trước',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        if (replyingToIndex == index)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 40.0,
                              top: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _replyController,
                                    decoration: InputDecoration(
                                      hintText: 'Nhập câu trả lời của bạn...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      () => onSendReply(
                                        index,
                                        comment['id'],
                                        widget.role != null
                                            ? widget.role
                                            : 'ROLE_CUSTOMER',
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Gửi',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
          if (widget.comments.length > widget.initialCommentCount)
            Center(
              child: TextButton(
                onPressed: toggleComments,
                child: Text(
                  displayedCommentCount < widget.comments.length
                      ? 'Xem thêm'
                      : 'Thu gọn',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
