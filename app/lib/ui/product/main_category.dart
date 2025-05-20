import 'package:app/globals/convert_money.dart';
import 'package:app/globals/sort_options_widget.dart';
import 'package:app/models/category_info.dart';
import 'package:app/models/product_info.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/repositories/cart_repository.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/product/main_brand.dart';
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

class CategoryPage extends StatefulWidget {
  final String selectedCategory;

  const CategoryPage({super.key, required this.selectedCategory});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late ApiService apiService;
  late CartRepository cartRepository;
  late CartService cartService;
  List<ProductInfo> products = [];
  List<CategoryInfo> brands = [];
  String? selectedBrand;

  String token = "";

  String selectedSort = "";
  String selectPrice = "Sắp xếp";
  late ScrollController _scrollController;
  bool isCollapsed = false;
  double lastOffset = 0;
  int? userId;
  bool _isLoading = true;

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

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
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

  Future<void> fetchProducts() async {
    try {
      final response = await apiService.getProductsByCategory(
        widget.selectedCategory,
      );
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
          onPressed: () => {Navigator.pop(context)},
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
            height: isCollapsed ? 0 : 40,
            child:
                isCollapsed
                    ? SizedBox.shrink()
                    : SortOptionsWidget(
                      selectPrice: selectPrice,
                      onSortChanged: (newValue) {
                        setState(() {
                          selectPrice = newValue;
                          applySorting();
                        });
                      },
                    ),
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
            // Phần ảnh
            Container(
              width: double.infinity,
              height: 150,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: Colors.white,
              ),
            ),
            // Phần nội dung
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120, // Giả lập tên sản phẩm
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 2),
                  Container(width: 80, height: 12, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                    width: 60, // Giả lập giá
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 40, // Giả lập giá cũ
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 30, // Giả lập giảm giá
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Nút "Thêm giỏ hàng"
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                height: 36, // Ước lượng chiều cao nút
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
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
              "Tìm kiếm ${widget.selectedCategory}",
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
          SizedBox(width: 10),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  brands.map((brand) => _buildFilterChip(brand.name)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = label == selectedBrand;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        elevation: 2,
        pressElevation: 5,
        onSelected: (_) {
          setState(() {
            selectedBrand = isSelected ? null : label;
          });
          _reloadDataWithFilter();
        },
      ),
    );
  }

  Future<void> _reloadDataWithFilter() async {
    // setState(() {
    //   _isLoading = true;
    // });

    // try {
    //   final response = await apiService.getProductsBySearchAdvance(
    //     widget.name,
    //     selectedBrand,
    //     minPrice,
    //     maxPrice,
    //     null,
    //   );

    //   setState(() {
    //     products = response;
    //   });

    //   applySorting();
    //   _pagingController.refresh();
    //   _fetchPage(0, response);
    // } catch (e) {
    //   print("Lỗi khi lọc: $e");
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
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

void showFilterBottomSheet(BuildContext context, List<CategoryInfo> brands) {
  print("HI");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return _FilterBottomSheet(brands: brands);
    },
  );
}

class _FilterBottomSheet extends StatefulWidget {
  final List<CategoryInfo> brands;

  const _FilterBottomSheet({super.key, required this.brands});
  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  double _minPrice = 10000;
  double _maxPrice = 10000000;
  RangeValues _currentRange = RangeValues(1000000, 5000000);
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  Set<String> selectedBrands = {};

  List<String> priceRanges = [
    "Dưới 1 triệu",
    "1 triệu - 2 triệu",
    "2 triệu - 5 triệu",
    "5 triệu - 10 triệu",
    "Trên 10 triệu",
  ];
  String? selectedPriceRange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Bộ lọc",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedBrands.clear();
                    selectedPriceRange = null;
                    _currentRange = RangeValues(_minPrice, _maxPrice);
                  });
                },
                child: Text(
                  "Thiết lập lại",
                  style: TextStyle(color: Colors.blue),
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
                  Text(
                    "Khoảng giá",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 10,
                    children: List.generate(priceRanges.length, (index) {
                      String price = priceRanges[index];
                      bool isSelected = selectedPriceRange == price;
                      return FilterChip(
                        label: Text(price),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedPriceRange = selected ? price : null;
                          });
                        },
                        selectedColor: Colors.blue.withOpacity(0.3),
                        checkmarkColor: Colors.white,
                      );
                    }),
                  ),
                  SizedBox(height: 10),

                  Text(
                    "Chọn khoảng giá (VNĐ)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      _buildPriceBox(_currentRange.start),
                      Expanded(child: Container(height: 2, color: Colors.grey)),
                      _buildPriceBox(_currentRange.end),
                    ],
                  ),
                  SizedBox(height: 10),
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
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRange = values;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    "Thương hiệu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 10,
                    children: List.generate(widget.brands.length, (index) {
                      String brand = widget.brands[index].name;
                      bool isSelected = selectedBrands.contains(brand);
                      return FilterChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedBrands.add(brand);
                            } else {
                              selectedBrands.remove(brand);
                            }
                          });
                        },
                        selectedColor: Colors.blue.withOpacity(0.3),
                        checkmarkColor: Colors.white,
                      );
                    }),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print("Khoảng giá đã chọn: $selectedPriceRange");
                  print(
                    "Khoảng giá cụ thể: ${_currentRange.start.toInt()} - ${_currentRange.end.toInt()} VNĐ",
                  );
                  print("Thương hiệu đã chọn: $selectedBrands");
                  Navigator.pop(context);
                },
                child: Text("Áp dụng"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(double value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        currencyFormat.format(value),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
