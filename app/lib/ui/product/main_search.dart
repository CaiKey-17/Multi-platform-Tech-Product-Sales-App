import 'package:app/globals/convert_money.dart';
import 'package:app/globals/sort_options_widget.dart';
import 'package:app/models/category_info.dart';
import 'package:app/models/product_info.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/repositories/cart_repository.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/product/product_details.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:app/ui/product/search_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class SearchByNamePage extends StatefulWidget {
  final String name;

  const SearchByNamePage({super.key, required this.name});

  @override
  State<SearchByNamePage> createState() => _SearchByNamePageState();
}

class _SearchByNamePageState extends State<SearchByNamePage> {
  late ApiService apiService;
  late CartRepository cartRepository;
  late CartService cartService;
  List<ProductInfo> products = [];
  List<CategoryInfo> brands = [];
  String? selectedBrand;
  int? selectedRating;

  double? minPrice;
  double? maxPrice;

  String token = "";
  int? userId;
  String selectedSort = "";
  String selectPrice = "Sắp xếp";
  late ScrollController _scrollController;
  bool isCollapsed = false;
  double lastOffset = 0;

  bool _isLoading = false;

  static const _pageSize = 10;
  bool _isFetching = false;

  final PagingController<int, ProductInfo> _pagingController = PagingController(
    firstPageKey: 0,
  );

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      userId = prefs.getInt('userId') ?? -1;
    });

    Future.microtask(() {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.fetchCartFromApi(userId);
    });
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  void showFilterBottomSheet(
    BuildContext context,
    List<CategoryInfo> brands,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FilterBottomSheet(brands: brands),
    );
    if (result != null) {
      setState(() {
        minPrice = result['minPrice'];
        maxPrice = result['maxPrice'];
        selectedBrand = result['brand'];
        selectedRating = result['rating'];
      });

      _reloadDataWithFilter();
    }
  }

  Future<void> _applyAdvancedFilter(double? minPrice, double? maxPrice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('minPrice', minPrice ?? 10000);
    await prefs.setDouble('maxPrice', maxPrice ?? 49000000);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.getProductsBySearchAdvance(
        widget.name,
        null,
        minPrice,
        maxPrice,
        null,
      );

      setState(() {
        products = response;
        _pagingController.refresh();
        _fetchPage(0, products);
      });
    } catch (e) {
      print("Lỗi lọc nâng cao: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await apiService.getProductsBySearch(widget.name);
      setState(() {
        products = response;
        _isLoading = false;
      });
      for (ProductInfo i in products) {
        print(i.name);
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchBrands() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await apiService.getListBrand();
      setState(() {
        brands = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    apiService = ApiService(Dio());
    cartRepository = CartRepository(apiService);
    cartService = CartService(cartRepository: cartRepository);
    _loadData();
  }

  void applySorting() {
    List<ProductInfo> sortedProducts = List.from(products);

    switch (selectPrice) {
      case "Giá thấp - cao":
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Giá cao - thấp":
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "A - Z":
        sortedProducts.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case "Z - A":
        sortedProducts.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      default:
        break;
    }

    _pagingController.refresh();
    _fetchPage(0, sortedProducts);
  }

  Future<void> _loadData() async {
    try {
      await fetchProducts();
      applySorting();

      await fetchBrands();
      _fetchPage(0, products);
    } catch (e) {
      print("Lỗi khi tải dữ liệu: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPage(int pageKey, List<ProductInfo> dataList) async {
    if (_isFetching) return;

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

  void _onScroll() {
    double currentOffset = _scrollController.offset;
    double maxOffset = _scrollController.position.maxScrollExtent;
    double delta = currentOffset - lastOffset;

    if (currentOffset <= 5) {
      if (isCollapsed) setState(() => isCollapsed = false);
    } else if (delta > 0 && !isCollapsed) {
      setState(() => isCollapsed = true);
    } else if (delta <= 0 && isCollapsed && currentOffset < maxOffset) {
      setState(() => isCollapsed = false);
    }

    if (currentOffset >= maxOffset - 200 &&
        !_isFetching &&
        _pagingController.nextPageKey != null) {
      _fetchPage(_pagingController.nextPageKey!, products);
    }

    lastOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('minPrice');
            await prefs.remove('maxPrice');
            await prefs.remove('selectedBrand');
            await prefs.remove('selectedRating');
            await prefs.remove('selectedPriceRange');

            Navigator.pop(context);
          },
        ),
        title: _buildSearchBar(),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,

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
      body: Column(
        children: [
          const SizedBox(height: 8),

          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: isCollapsed ? 0 : 50,
            child: isCollapsed ? SizedBox.shrink() : _buildFilterBar(brands),
          ),

          Expanded(
            child: _isLoading ? _buildGridViewShimmer() : _buildGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridViewShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.6,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildProductItemShimmer(),
    );
  }

  Widget _buildProductItemShimmer() {
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

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 36,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 252, 255),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.search, color: Colors.grey, size: 19),
            ),
            Text(
              "Kết quả tìm `${widget.name}`",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<CategoryInfo> brands) {
    return Container(
      height: 50,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () => showFilterBottomSheet(context, brands),
            icon: Icon(Icons.filter_list, color: Colors.blue),
            label: Text(
              "Lọc",
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SortOptionsWidget(
            selectPrice: selectPrice,
            onSortChanged: (newValue) {
              setState(() {
                selectPrice = newValue;
                applySorting();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _reloadDataWithFilter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.getProductsBySearchAdvance(
        widget.name,
        selectedBrand,
        minPrice,
        maxPrice,
        selectedRating?.toDouble(),
      );

      setState(() {
        products = response;
      });

      applySorting();
      _pagingController.refresh();
      _fetchPage(0, response);
    } catch (e) {
      print("Lỗi khi lọc: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildGridView() {
    return ValueListenableBuilder(
      valueListenable: _pagingController,
      builder: (context, PagingState<int, ProductInfo> value, child) {
        final items = value.itemList ?? [];
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.53,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductItem(items[index]),
                  childCount: items.length,
                ),
              ),
            ),
            if (_isFetching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
              ),
            if (value.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Có lỗi xảy ra khi tải dữ liệu',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductItem(ProductInfo product) {
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  product.image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? "",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                  const SizedBox(height: 4),
                  if (product.discountPercent > 0)
                    Row(
                      children: [
                        Text(
                          product.oldPrice.toString() ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "- ${product.discountPercent}%" ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
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
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<CategoryInfo> brands;

  const _FilterBottomSheet({super.key, required this.brands});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  double _minPrice = 10000;
  double _maxPrice = 49000000;

  RangeValues _currentRange = RangeValues(1000000, 5000000);
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  String? selectedBrand;
  int? selectedRating;
  String? selectedPriceRange;

  List<String> priceRanges = [
    "Dưới 1 triệu",
    "1 triệu - 2 triệu",
    "2 triệu - 5 triệu",
    "5 triệu - 10 triệu",
    "Trên 10 triệu",
  ];

  @override
  void initState() {
    super.initState();
    _loadFilterSettings();
  }

  Future<void> _loadFilterSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double minPrice = prefs.getDouble('minPrice') ?? 10000;
    double maxPrice = prefs.getDouble('maxPrice') ?? 49000000;
    String? savedBrand = prefs.getString('selectedBrand');
    int? savedRating = prefs.getInt('selectedRating');
    String? savedPriceRange = prefs.getString('selectedPriceRange');

    setState(() {
      _currentRange = RangeValues(minPrice, maxPrice);
      selectedBrand = savedBrand;
      selectedRating = savedRating;
      selectedPriceRange = savedPriceRange;

      if (savedPriceRange != null) {
        switch (savedPriceRange) {
          case "Dưới 1 triệu":
            _currentRange = RangeValues(10000, 1000000);
            break;
          case "1 triệu - 2 triệu":
            _currentRange = RangeValues(1000000, 2000000);
            break;
          case "2 triệu - 5 triệu":
            _currentRange = RangeValues(2000000, 5000000);
            break;
          case "5 triệu - 10 triệu":
            _currentRange = RangeValues(5000000, 10000000);
            break;
          case "Trên 10 triệu":
            _currentRange = RangeValues(10000000, 49000000);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Bộ lọc",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBrand = null;
                      selectedPriceRange = null;
                      selectedRating = null;
                      _currentRange = RangeValues(_minPrice, _maxPrice);
                    });
                  },
                  child: Text(
                    "Thiết lập lại",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Khoảng giá", style: _titleStyle()),
                    Wrap(
                      spacing: 10,
                      children:
                          priceRanges.map((price) {
                            bool isSelected = selectedPriceRange == price;
                            return FilterChip(
                              label: Text(
                                price,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.blue,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedPriceRange = selected ? price : null;
                                  switch (selectedPriceRange) {
                                    case "Dưới 1 triệu":
                                      _currentRange = RangeValues(
                                        10000,
                                        1000000,
                                      );
                                      break;
                                    case "1 triệu - 2 triệu":
                                      _currentRange = RangeValues(
                                        1000000,
                                        2000000,
                                      );
                                      break;
                                    case "2 triệu - 5 triệu":
                                      _currentRange = RangeValues(
                                        2000000,
                                        5000000,
                                      );
                                      break;
                                    case "5 triệu - 10 triệu":
                                      _currentRange = RangeValues(
                                        5000000,
                                        10000000,
                                      );
                                      break;
                                    case "Trên 10 triệu":
                                      _currentRange = RangeValues(
                                        10000000,
                                        49000000,
                                      );
                                      break;
                                    default:
                                      _currentRange = RangeValues(
                                        _minPrice,
                                        _maxPrice,
                                      );
                                  }
                                });
                              },
                              selectedColor: Colors.blue.withOpacity(0.7),
                              backgroundColor: Colors.white,

                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 10),
                    Text("Chọn khoảng giá (VNĐ)", style: _titleStyle()),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPriceBox(_currentRange.start),
                        Expanded(
                          child: Container(height: 2, color: Colors.grey),
                        ),
                        _buildPriceBox(_currentRange.end),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: Colors.blue.shade200,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: Colors.blue,
                        overlayColor: Colors.blue.withOpacity(0.2),
                      ),
                      child: RangeSlider(
                        values: _currentRange,
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: 100,
                        onChanged: (values) {
                          setState(() {
                            _currentRange = values;
                            selectedPriceRange = null;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Thương hiệu", style: _titleStyle()),
                    Wrap(
                      spacing: 8,
                      children:
                          widget.brands.map((brand) {
                            bool isSelected = selectedBrand == brand.name;
                            return FilterChip(
                              label: Text(
                                brand.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.blue,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedBrand = selected ? brand.name : null;
                                });
                              },
                              selectedColor: Colors.blue.withOpacity(0.7),
                              backgroundColor: Colors.white,

                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text("Chất lượng sản phẩm", style: _titleStyle()),
                    Wrap(
                      spacing: 8,
                      children: List.generate(5, (index) {
                        int rating = index + 1;
                        bool isSelected = selectedRating == rating;
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              rating,
                              (_) => Icon(
                                Icons.star,
                                size: 16,
                                color: isSelected ? Colors.white : Colors.amber,
                              ),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedRating = selected ? rating : null;
                            });
                          },
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setDouble('minPrice', _currentRange.start);
                    await prefs.setDouble('maxPrice', _currentRange.end);
                    if (selectedBrand != null) {
                      await prefs.setString('selectedBrand', selectedBrand!);
                    } else {
                      await prefs.remove('selectedBrand');
                    }
                    if (selectedRating != null) {
                      await prefs.setInt('selectedRating', selectedRating!);
                    } else {
                      await prefs.remove('selectedRating');
                    }
                    if (selectedPriceRange != null) {
                      await prefs.setString(
                        'selectedPriceRange',
                        selectedPriceRange!,
                      );
                    } else {
                      await prefs.remove('selectedPriceRange');
                    }

                    Navigator.pop(context, {
                      'minPrice': _currentRange.start,
                      'maxPrice': _currentRange.end,
                      'brand': selectedBrand,
                      'rating': selectedRating,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Áp dụng", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle() =>
      TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16);

  Widget _buildPriceBox(double value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        currencyFormat.format(value),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
