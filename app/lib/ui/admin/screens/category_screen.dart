import 'package:app/luan/models/category_info.dart';
import 'package:app/providers/brand_image_picker.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String token = "";
  bool isLoading = false;
  List<CategoryInfo> categories = [];

  late ApiAdminService apiAdminService;

  Future<void> fetchCategoriesManager() async {
    setState(() {
      isLoading = true;
    });
    try {
      final categoriesData = await apiAdminService.getAllCategories();
      setState(() {
        categories = categoriesData;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách loại sản phẩm: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    apiAdminService = ApiAdminService(Dio());
    _loadUserData();
    fetchCategoriesManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          "Quản lý loại sản phẩm",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: SideBar(token: token),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: _buildCategoryList(context))],
                ),
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _showCategoryDialog(context, isEdit: false);
        },
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: BrandImagePicker(imageUrl: category.image),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name ?? 'Không có tên',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPopupMenu(context, index),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context, int categoryIndex) {
    return PopupMenuButton<String>(
      color: Colors.white,
      onSelected: (value) {
        if (value == 'edit') {
          _showCategoryDialog(
            context,
            isEdit: true,
            categoryIndex: categoryIndex,
          );
        } else if (value == 'delete') {
          _confirmDeleteUser(context, categoryIndex);
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
      icon: Icon(Icons.more_vert, color: Colors.grey[700]),
    );
  }

  void _showCategoryDialog(
    BuildContext context, {
    required bool isEdit,
    int? categoryIndex,
  }) {
    final category = isEdit ? categories[categoryIndex!] : null;
    TextEditingController nameController = TextEditingController(
      text: isEdit ? category!.name ?? '' : '',
    );
    String? imageUrl = isEdit ? category!.image : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                isEdit ? "Chỉnh sửa loại" : "Thêm loại",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandImagePicker(
                      imageUrl: imageUrl,
                      onImageChanged: (newImageUrl) {
                        setDialogState(() {
                          imageUrl = newImageUrl;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      enabled: !isEdit,
                      decoration: InputDecoration(
                        labelText: "Tên loại",
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Đóng",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vui lòng nhập loại sản phẩm")),
                      );
                      return;
                    }
                    try {
                      if (isEdit) {
                        final oldName = category!.name ?? '';
                        if (oldName.isEmpty) {
                          throw Exception("Tên thương hiệu cũ không hợp lệ");
                        }
                        await apiAdminService.updateCategory(
                          oldName,
                          imageUrl!,
                        );
                        print("Đường dẫn ảnh mới: $imageUrl");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Cập nhật loại sản phẩm thành công"),
                          ),
                        );
                      } else {
                        await apiAdminService.createCategory(
                          nameController.text.trim(),
                          imageUrl!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Tạo loại sản phẩm thành công"),
                          ),
                        );
                      }
                      await fetchCategoriesManager();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                    }
                  },
                  child: Text(
                    "Xong",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(BuildContext context, int categoryIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa ${categories[categoryIndex].name} không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiAdminService.deleteCategory(
                    categories[categoryIndex].name!,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Xóa loại sản phẩm thành công")),
                  );
                  await fetchCategoriesManager();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi khi xóa: $e")));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Xóa", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
