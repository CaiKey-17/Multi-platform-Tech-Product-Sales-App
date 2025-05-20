import 'package:app/models/category_info.dart';
import 'package:app/ui/product/main_brand.dart';
import 'package:app/ui/product/main_category.dart';
import 'package:app/ui/product/search_page.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';

class CategoryPageList extends StatefulWidget {
  const CategoryPageList({super.key});

  @override
  State<CategoryPageList> createState() => _CategoryPageListState();
}

class _CategoryPageListState extends State<CategoryPageList> {
  late ApiService apiService;
  bool isLoading = true;
  List<CategoryInfo> categories = [];
  List<CategoryInfo> brands = [];

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    fetchCategories();
    fetchBrands();
  }

  Future<void> fetchCategories() async {
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

  // final List<Map<String, String>> categories1 = [
  //   {"name": "Laptop", "image": "assets/images/laptop.webp"},
  //   {"name": "Sản phẩm Apple", "image": "assets/images/laptop.webp"},
  //   {"name": "PC - Máy tính bàn", "image": "assets/images/laptop.webp"},
  //   {"name": "Điện máy", "image": "assets/images/laptop.webp"},
  //   {"name": "Điện gia dụng", "image": "assets/images/laptop.webp"},
  //   {"name": "Màn hình", "image": "assets/images/laptop.webp"},
  //   {"name": "Linh kiện máy tính", "image": "assets/images/laptop.webp"},
  //   {"name": "Gaming Gear", "image": "assets/images/laptop.webp"},
  //   {"name": "Phụ kiện", "image": "assets/images/laptop.webp"},
  //   {"name": "Máy in in in in in in in ", "image": "assets/images/laptop.webp"},
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _buildSearchBar(),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection("Danh mục sản phẩm", categories),
                _buildBrandSection("Danh mục thương hiệu", brands),
                SizedBox(height: 55),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection(String title, List<CategoryInfo> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 10, top: 5),
          child: const Divider(),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 6 : 4;
            return GridView.builder(
              padding: EdgeInsets.only(bottom: 12),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.88,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildBrandItem(items[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<CategoryInfo> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 10, top: 5),
          child: const Divider(),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 6 : 4;
            return GridView.builder(
              padding: EdgeInsets.only(bottom: 12),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.88,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(items[index]);
              },
            );
          },
        ),
      ],
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
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 37,
                    padding: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Phần chứa icon camera
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
                      print("Camera pressed");
                    },
                  ),
                ),
              ],
            ),
            // Phần chứa icon search và text, đặt ở giữa nhờ Stack
            Row(
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryInfo category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(selectedCategory: category.name),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  category.images != null
                      ? Image.network(category.images!, fit: BoxFit.cover)
                      : Icon(Icons.category, size: 40, color: Colors.grey),
            ),
          ),
          SizedBox(height: 5),
          SizedBox(
            height: 37,
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandItem(CategoryInfo category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrandPage(selectedBrand: category.name),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white, // nền trắng
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  category.images != null
                      ? Image.network(category.images!, fit: BoxFit.cover)
                      : Icon(
                        Icons.category,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
            ),
          ),

          SizedBox(height: 5),
          SizedBox(
            height: 37,
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
