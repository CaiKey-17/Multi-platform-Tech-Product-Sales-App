import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:app/ui/ai/detect_image.dart';
import 'package:app/ui/product/main_search.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:app/data/banner.dart';
import 'package:app/globals/convert_money.dart';
import 'package:app/models/product_info.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/services/chat_service.dart';
import 'package:app/ui/chat/chat_list_page.dart';
import 'package:app/ui/product/main_category.dart';
import 'package:app/ui/product/product_details.dart';
import 'package:app/ui/product/search_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/category_info.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_points_provider.dart';
import '../../repositories/cart_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer countdownTimer;
  late Duration remainingTime = const Duration(
    hours: 32,
    minutes: 40,
    seconds: 32,
  );

  late CartRepository cartRepository;
  late CartService cartService;
  late ApiService apiService;
  static const _pageSize = 5;
  bool isLoading = true;
  bool isCollapsed = false;
  String fullName = "";
  int? userId;
  int points = 0;
  bool _isFetching = false;
  bool _isLoading = true;
  bool _isLoadingPromotion = true;

  int _currentIndex = 0;
  String token = "";
  List<CategoryInfo> categories = [];
  List<ProductInfo> productsPromotion = [];
  List<ProductInfo> productsNew = [];
  List<ProductInfo> productsBestSeller = [];

  List<ProductInfo> productsPc = [];
  List<ProductInfo> productsLaptop = [];
  List<ProductInfo> productsPhone = [];
  List<ProductInfo> productsKeyboard = [];
  List<ProductInfo> productsMonitor = [];

  List<CategoryInfo> brands = [];

  File? _image;
  String _result = "";

  final PagingController<int, ProductInfo> _pagingController = PagingController(
    firstPageKey: 0,
  );

  final PagingController<int, ProductInfo> _pagingController2 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController3 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController4 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController5 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController6 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController7 =
      PagingController(firstPageKey: 0);

  late ScrollController _scrollController;
  late ScrollController _scrollController1;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "";
      token = prefs.getString('token') ?? "";
      userId = prefs.getInt('userId') ?? -1;
    });
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getListCategory();
      setState(() {
        categories = response;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsPc() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsPc();
      setState(() {
        productsPc = response;
        _pagingController6.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController6, productsPc);
        });
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsLaptop() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsLaptop();
      setState(() {
        productsLaptop = response;
        _pagingController3.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController3, productsLaptop);
        });
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsPhone() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsPhone();
      setState(() {
        productsPhone = response;
        _pagingController4.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController4, productsPhone);
        });
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsMonitor() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsMonitor();
      setState(() {
        productsMonitor = response;
        _pagingController5.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController5, productsMonitor);
        });
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsKeyboard() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsKeyBoard();
      setState(() {
        productsKeyboard = response;
        _pagingController7.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController7, productsKeyboard);
        });
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsNew() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsNew();
      setState(() {
        productsNew = response;
        _pagingController.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController, productsNew);
        });
        _fetchPage1(5, productsNew);
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsBestSeller() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getProductsBestSeller();
      setState(() {
        productsBestSeller = response;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBrands() async {
    try {
      final response = await apiService.getListBrand();
      setState(() {
        brands = response;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsPromotion() async {
    setState(() {
      _isLoadingPromotion = true;
    });
    try {
      final response = await apiService.getProductsPromotion();
      setState(() {
        productsPromotion = response;
        final newItems = productsPromotion.take(_pageSize).toList();
        final isLastPage =
            newItems.length < _pageSize ||
            newItems.length == productsPromotion.length;
        if (isLastPage) {
          _pagingController2.appendLastPage(newItems);
        } else {
          _pagingController2.appendPage(newItems, 1);
        }

        _pagingController2.addPageRequestListener((pageKey) {
          _fetchPage(pageKey, _pagingController2, productsPromotion);
        });

        _isLoadingPromotion = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        _isLoadingPromotion = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController1 = ScrollController();
    _scrollController.addListener(_onScroll);
    Provider.of<UserPointsProvider>(
      context,
      listen: false,
    ).loadPointsFromPrefs();
    _loadUserData();
    remainingTime = const Duration(hours: 32, minutes: 40, seconds: 32);

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (remainingTime.inSeconds > 0) {
            remainingTime -= const Duration(seconds: 1);
          } else {
            timer.cancel();
          }
        });
      }
    });

    apiService = ApiService(Dio());
    cartRepository = CartRepository(apiService);
    cartService = CartService(cartRepository: cartRepository);
    //1
    fetchCategories();

    fetchProductsPromotion();

    //3
    fetchProductsNew();
    fetchProductsBestSeller();
    //5
    fetchProductsLaptop();
    fetchProductsKeyboard();
    fetchProductsPc();
    fetchProductsPhone();
    fetchProductsMonitor();
    //

    fetchBrands();
    _loadInitialData();
  }

  Future<void> _fetchPage(
    int pageKey,
    PagingController<int, ProductInfo> controller,
    List<ProductInfo> dataList,
  ) async {
    try {
      final newItems =
          List.generate(_pageSize, (index) {
            final dataIndex = pageKey * _pageSize + index;
            return dataIndex < dataList.length ? dataList[dataIndex] : null;
          }).whereType<ProductInfo>().toList();

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  Future<void> _fetchPage1(int pageKey, List<ProductInfo> dataList) async {
    setState(() {
      _isFetching = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final newItems =
          List.generate(_pageSize, (index) {
            final dataIndex = pageKey * _pageSize + index;
            return dataIndex < dataList.length ? dataList[dataIndex] : null;
          }).whereType<ProductInfo>().toList();

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  double lastOffset = 0;

  void _onScroll() {
    double currentOffset = _scrollController.offset;
    double delta = currentOffset - lastOffset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    // if (currentOffset >= maxScrollExtent - 200 &&
    //     !_isFetching &&
    //     _pagingController.nextPageKey != null) {
    //   _fetchPage1(_pagingController.nextPageKey!, productsPromotion);
    // }

    if (delta > 0 && !isCollapsed) {
      setState(() => isCollapsed = true);
    } else if (delta < 0 && isCollapsed && currentOffset == 0) {
      setState(() => isCollapsed = false);
    }

    lastOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    countdownTimer.cancel();
    _scrollController.dispose();
    _scrollController1.dispose();
    _pagingController.dispose();
    _pagingController2.dispose();
    _pagingController3.dispose();
    _pagingController4.dispose();
    _pagingController5.dispose();
    _pagingController6.dispose();
    _pagingController7.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours giờ $minutes phút $seconds giây';
  }

  bool isNewProductSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 100.0,
              backgroundColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  bool isFullyCollapsed =
                      constraints.maxHeight == kToolbarHeight;

                  return Container(
                    decoration: BoxDecoration(
                      gradient:
                          isFullyCollapsed
                              ? LinearGradient(
                                colors: [Colors.blue, Colors.blue],
                              )
                              : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blue,
                                  Colors.blue,
                                  Colors.white,
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCollapsed)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _isLoading
                                    ? _buildGreetingShimmer()
                                    : Text(
                                      "Xin chào ${fullName.isNotEmpty ? fullName : 'bạn'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Pacifico',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                Row(
                                  children: [
                                    _isLoading
                                        ? _buildPointsShimmer()
                                        : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(
                                              40,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade700,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '🪙 ${context.watch<UserPointsProvider>().formattedPoints}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ChatScreen(userId: userId!),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.support_agent_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildSearchBar()),
                                if (isCollapsed) SizedBox(width: 8),
                                if (isCollapsed)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  ChatScreen(userId: userId!),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.support_agent_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _isLoading
                    ? _buildHorizontalListShimmer()
                    : _buildHorizontalList(),
                _isLoading ? _buildBannerShimmer() : _buildBanner(),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView(_pagingController2),
                SizedBox(height: 10),
                _isLoading
                    ? _buildProductSwitcherShimmer()
                    : _buildProductSwitcher(),
                _isLoading
                    ? _buildProductListShimmer()
                    : _buildProductList(
                      isNewProductSelected ? productsNew : productsBestSeller,
                    ),
                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("Laptop", () {
                      print("Laptop");
                    }),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController3),
                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("Điện thoại", () {
                      print("Điện thoại");
                    }),

                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController4),
                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("Màn hình", () {
                      print("Màn hình");
                    }),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController5),

                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("PC - Máy tính bàn", () {
                      print("PC - Máy tính bàn");
                    }),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController6),

                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("Bàn phím", () {
                      print("Bàn phím");
                    }),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController7),

                _isLoading ? _buildGridViewShimmer() : _buildGridView(),
                const SizedBox(height: 60),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
      },
      child: Container(
        height: 37,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 252, 255),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 37,
                    padding: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 37,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      ImageUploader(
                        context: context,
                        onResult: (result) {},
                      ).pickImageAndUpload();
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 19),
                  SizedBox(width: 8),
                  Text(
                    "Bạn muốn mua gì hôm nay",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 190,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategoryPage(
                          selectedCategory: categories[index].name,
                        ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        categories[index].images ??
                            "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                              padding: EdgeInsets.all(8),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/images/gaming.webp");
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    categories[index].name,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanner() {
    double screenWidth = MediaQuery.of(context).size.width;
    double bannerHeight =
        screenWidth > 1024
            ? 350
            : screenWidth > 600
            ? 250
            : 180;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: AppBanner.imgBanner.length,
            itemBuilder: (context, index, realIndex) {
              return CachedNetworkImage(
                imageUrl: AppBanner.imgBanner[index],
                imageBuilder:
                    (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                placeholder:
                    (context, url) =>
                        Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
            },
            options: CarouselOptions(
              height: bannerHeight,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              viewportFraction: 0.8,
              aspectRatio: 16 / 9,
              initialPage: 0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                AppBanner.imgBanner.length,
                (index) => Container(
                  width: _currentIndex == index ? 17 : 7,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        _currentIndex == index
                            ? Colors.blue
                            : const Color.fromARGB(255, 174, 185, 184),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalListShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 140,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 20, color: Colors.white),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBannerShimmer() {
    double screenWidth = MediaQuery.of(context).size.width;
    double bannerHeight =
        screenWidth > 1024
            ? 350
            : screenWidth > 600
            ? 250
            : 180;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: bannerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title, VoidCallback onSeeMore) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;
        return Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSmallScreen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildHeader(title)),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildBrandList(brands),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CategoryPage(selectedCategory: title),
                          ),
                        );
                      },
                      child: Text(
                        "Xem thêm",
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ],
                ),

              if (isSmallScreen) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildHeader(title)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CategoryPage(selectedCategory: title),
                          ),
                        );
                      },
                      child: Text(
                        "Xem thêm",
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildBrandList(brands),
                  ),
                ),
              ],
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[300],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle1(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: _buildHeader(title),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBrandList(List<CategoryInfo> brands) {
    return Row(
      children:
          brands.map((brand) {
            return Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(brand.name, style: TextStyle(fontSize: 12)),
            );
          }).toList(),
    );
  }

  Widget _buildTimeBox(int value) {
    return Container(
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.red, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(203, 244, 67, 54).withOpacity(1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value.toString().padLeft(2, '0'),
        style: GoogleFonts.rajdhani(
          color: Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildListView(PagingController<int, ProductInfo> controller) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/nengiamgia.webp',
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
          ),
        ),
        Container(
          height: 480,
          color: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Giảm cực sốc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildTimeBox(remainingTime.inHours),
                        const SizedBox(width: 4),
                        const Text(
                          ":",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        _buildTimeBox(remainingTime.inMinutes % 60),
                        const SizedBox(width: 4),
                        const Text(
                          ":",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        _buildTimeBox(remainingTime.inSeconds % 60),
                      ],
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchByNamePage(name: ""),
                          ),
                        );
                      },
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PagedListView<int, ProductInfo>(
                  pagingController: controller,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(8),
                  builderDelegate: PagedChildBuilderDelegate<ProductInfo>(
                    itemBuilder: (context, product, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ProductPage(productId: product.id),
                            ),
                          );
                        },
                        child: Container(
                          width: 180,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      child: Image.network(
                                        product.image,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 8,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/giamgia.svg',
                                            width: 40,
                                            height: 40,
                                          ),
                                          Positioned(
                                            child: Text(
                                              product.discountLabel,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "${ConvertMoney.currencyFormatter.format(product.price)} ₫",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (product.discountPercent > 0)
                                      Row(
                                        children: [
                                          Text(
                                            "${ConvertMoney.currencyFormatter.format(product.oldPrice)} ₫",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(width: 4),

                                          Text(
                                            "- ${product.discountPercent}%" ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: List.generate(5, (index) {
                                        if (index < product.rating.floor()) {
                                          // Sao đầy
                                          return const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        } else if (index < product.rating &&
                                            (product.rating - index) >= 0.5) {
                                          // Sao nửa
                                          return const Icon(
                                            Icons.star_half,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        } else {
                                          // Sao trống
                                          return const Icon(
                                            Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        }
                                      }),
                                    ),
                                  ],
                                ),
                              ),

                              Spacer(),
                              Padding(
                                padding: EdgeInsets.all(8),
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
                                      side: BorderSide(
                                        color: Colors.blue,
                                        width: 1,
                                      ),
                                      foregroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 9,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Thêm giỏ hàng",
                                      style: TextStyle(fontSize: 14),
                                    ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView1(PagingController<int, ProductInfo> controller) {
    return Container(
      height: 420,
      child: PagedListView<int, ProductInfo>(
        pagingController: controller,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(8),
        builderDelegate: PagedChildBuilderDelegate<ProductInfo>(
          itemBuilder: (context, product, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(productId: product.id),
                  ),
                );
              },
              child: Container(
                width: 180,
                margin: EdgeInsets.only(right: 10),
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
                      padding: EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          product.image,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${ConvertMoney.currencyFormatter.format(product.price)} ₫",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (index) {
                              if (index < product.rating.floor()) {
                                // Sao đầy
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              } else if (index < product.rating &&
                                  (product.rating - index) >= 0.5) {
                                // Sao nửa
                                return const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              } else {
                                // Sao trống
                                return const Icon(
                                  Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.all(8),
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
                            side: BorderSide(color: Colors.blue, width: 1),
                            foregroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Thêm giỏ hàng",
                            style: TextStyle(fontSize: 14),
                          ),
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
    );
  }

  String backgroundImage =
      "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png";

  Widget _buildProductList(List<ProductInfo> products) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        controller: _scrollController1,
        padding: EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(productId: product.id),
                ),
              );
            },
            child: Container(
              width: 180,
              margin: EdgeInsets.only(right: 8),
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
                    padding: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.network(
                        product.image,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          products[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          products[index].description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${ConvertMoney.currencyFormatter.format(products[index].price)} ₫",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.discountPercent > 0)
                          Row(
                            children: [
                              Text(
                                "${ConvertMoney.currencyFormatter.format(products[index].oldPrice)} ₫",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "- ${product.discountPercent}%" ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            if (index < product.rating.floor()) {
                              // Sao đầy
                              return const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              );
                            } else if (index < product.rating &&
                                (product.rating - index) >= 0.5) {
                              // Sao nửa
                              return const Icon(
                                Icons.star_half,
                                color: Colors.amber,
                                size: 16,
                              );
                            } else {
                              // Sao trống
                              return const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.all(8),
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
                          side: BorderSide(color: Colors.blue, width: 1),
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Thêm giỏ hàng",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isNewProductSelected = true;
              _scrollController1.jumpTo(0);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              image:
                  isNewProductSelected
                      ? DecorationImage(
                        image: NetworkImage(
                          "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png",
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
              color: isNewProductSelected ? null : Colors.white,
            ),
            child: Text(
              "Sản phẩm mới",
              style: TextStyle(
                color: Colors.black,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isNewProductSelected = false;
              _scrollController1.jumpTo(0);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              image:
                  !isNewProductSelected
                      ? DecorationImage(
                        image: NetworkImage(
                          "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png",
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
              color: !isNewProductSelected ? null : Colors.white,
            ),
            child: Text(
              "Sản phẩm bán chạy",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(ProductInfo product) {
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              product.image,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.description ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 1,
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
                const SizedBox(height: 4),
                if (product.discountPercent > 0)
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
                        "- ${product.discountPercent}%" ?? "",
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
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
  }

  Widget _buildGridView() {
    return ValueListenableBuilder(
      valueListenable: _pagingController,
      builder: (context, PagingState<int, ProductInfo> value, child) {
        final items = value.itemList ?? [];
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.53,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _buildProductItem(items[index]),
            ),
            if (_isFetching)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Đang tải thêm ...",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            if (value.error != null)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Có lỗi xảy ra khi tải dữ liệu',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

Widget _buildGreetingShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(width: 150, height: 20, color: Colors.white),
  );
}

Widget _buildPointsShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: 60,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
    ),
  );
}

Widget _buildListViewShimmer() {
  return Container(
    height: 480,
    color: null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 100, height: 18, color: Colors.white),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 60, height: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 420,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(8),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 180,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 8,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120,
                                height: 14,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 150,
                                height: 12,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    width: 40,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    width: 16,
                                    height: 16,
                                    margin: EdgeInsets.only(right: 2),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            width: double.infinity,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
        ),
      ],
    ),
  );
}

Widget _buildProductSwitcherShimmer() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(width: 80, height: 16, color: Colors.grey[300]),
        ),
      ),
      const SizedBox(width: 8),
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(width: 120, height: 16, color: Colors.grey[300]),
        ),
      ),
    ],
  );
}

Widget _buildProductListShimmer() {
  return Container(
    height: 420,
    child: ListView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.horizontal,
      itemCount: 8,
      itemBuilder: (context, index) {
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
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 14, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 2),
                      Container(width: 80, height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 60, height: 16, color: Colors.white),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 40, height: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Container(width: 30, height: 12, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 2),
                            color: Colors.white,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildTitleShimmer() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 100, height: 20, color: Colors.white),
            ),

            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 60, height: 14, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 1, color: Colors.grey[300]),
      ],
    ),
  );
}

Widget _buildGridViewShimmer() {
  return Column(
    children: [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.53,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _buildProductItemShimmer(),
      ),
    ],
  );
}

Widget _buildProductItemShimmer() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              color: Colors.white,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 14, color: Colors.white),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 2),
                Container(width: 80, height: 12, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 60, height: 16, color: Colors.white),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 40, height: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Container(width: 30, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
