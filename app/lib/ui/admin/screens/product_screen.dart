import 'package:app/luan/models/product_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/ui/admin/screens/product_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String token = "";
  late ApiAdminService apiAdminService;
  bool isLoading = false;
  List<ProductInfo> products = [];
  String? errorMessage;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  Future<void> fetchProductsManager() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final productsData = await apiAdminService.getAllProducts();
      setState(() {
        products = productsData;
        isLoading = false;
      });
    } catch (e) {
      errorMessage = "Không thể tải danh sách sản phẩm: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách sản phẩm: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId, int index) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Lấy danh sách các biến thể của sản phẩm
      final variants = await apiAdminService.getVariantsByProductId(productId);
      
      // Xóa từng biến thể và các màu sắc liên quan
      for (var variant in variants) {
        if (variant.id != 0) {
          // Lấy danh sách màu sắc của biến thể
          final colors = await apiAdminService.getColorsByVariantId(variant.id);
          for (var color in colors) {
            developer.log("Deleting color with ID: ${color.id}");
            await apiAdminService.deleteProductColor(color.id);
          }
          developer.log("Deleting variant with ID: ${variant.id}");
          await apiAdminService.deleteProductVariant(variant.id);
        }
      }
      
      // Xóa sản phẩm
      developer.log("Deleting product with ID: $productId");
      await apiAdminService.deleteProduct(productId);

      // Cập nhật danh sách sản phẩm
      setState(() {
        products.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xóa sản phẩm thành công")),
      );
    } catch (e) {
      developer.log("Error deleting product: $e");
      setState(() {
        errorMessage = "Không thể xóa sản phẩm: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể xóa sản phẩm: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apiAdminService = ApiAdminService(Dio());
    _loadUserData();
    fetchProductsManager();
  }

  String sortOption = "Mặc định";
  List<String> sortOptions = ["Mặc định", "A - Z", "Z - A"];
  bool _showSortBar = true;
  bool _showSearchOptions = false;
  bool _showSearchField = false;
  String _searchType = "";
  final TextEditingController _searchController = TextEditingController();

  String formatCurrency(double amount) {
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  void _sortProducts() {
    setState(() {
      if (sortOption == "A - Z") {
        products.sort((a, b) => a.name!.compareTo(b.name!));
      } else if (sortOption == "Z - A") {
        products.sort((a, b) => b.name!.compareTo(a.name!));
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchProductsManager();
      } else {
        products =
            products.where((product) {
              if (_searchType == "category") {
                return product.fkCategory!.toLowerCase().contains(
                  query.toLowerCase(),
                );
              } else if (_searchType == "brand") {
                return product.fkBrand!.toLowerCase().contains(
                  query.toLowerCase(),
                );
              }
              return true;
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(token: token),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Quản lý sản phẩm",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (isLoading) CircularProgressIndicator(),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ProductDetailScreen(isEdit: false, productInfo: null),
            ),
          );
          await fetchProductsManager();
        },
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: [
        if (_showSortBar && !_showSearchField)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: sortOption,
                  items:
                      sortOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        sortOption = newValue;
                        _sortProducts();
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _showSearchOptions = !_showSearchOptions;
                    });
                  },
                ),
              ],
            ),
          ),
        if (_showSearchOptions && !_showSearchField)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSearchField = true;
                      _showSortBar = false;
                      _showSearchOptions = false;
                      _searchType = "category";
                      _searchController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Tìm kiếm theo loại"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSearchField = true;
                      _showSortBar = false;
                      _showSearchOptions = false;
                      _searchType = "brand";
                      _searchController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Tìm kiếm theo hãng"),
                ),
              ],
            ),
          ),
        if (_showSearchField)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          _searchType == "category"
                              ? "Nhập loại sản phẩm..."
                              : "Nhập hãng sản phẩm...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _showSearchField = false;
                            _showSortBar = true;
                            _searchController.clear();
                            fetchProductsManager();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _filterProducts(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 1.5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductImage(product.mainImage),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mã: ${product.id}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      product.name ?? "Không có tên",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      "Loại: ${product.fkCategory ?? 'Không xác định'}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      "Hãng: ${product.fkBrand ?? 'Không xác định'}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Xác nhận xóa"),
                                content: Text(
                                  "Bạn có chắc chắn muốn xóa sản phẩm '${product.name}'? Tất cả biến thể và màu sắc liên quan sẽ bị xóa.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context); // Đóng dialog
                                      await _deleteProduct(product.id!, index);
                                    },
                                    child: Text(
                                      "Xóa",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 1,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailScreen(
                                      isEdit: true,
                                      productInfo: product,
                                    ),
                              ),
                            );
                            await fetchProductsManager();
                          },
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
    );
  }

  Widget _buildProductImage(String? imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        image: DecorationImage(
          image:
              imagePath != null
                  ? NetworkImage(imagePath)
                  : AssetImage('assets/images/default.jpg') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}