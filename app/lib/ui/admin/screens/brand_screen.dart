import 'package:app/luan/models/brand_info.dart';
import 'package:app/providers/brand_image_picker.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';

class BrandScreen extends StatefulWidget {
  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  String token = "";
  bool isLoading = false;
  List<BrandInfo> brands = [];

  late ApiAdminService apiAdminService;

  Future<void> fetchBrandsManager() async {
    setState(() {
      isLoading = true;
    });
    try {
      final brandsData = await apiAdminService.getAllBrands();
      setState(() {
        brands = brandsData;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách thương hiệu: $e")),
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
    fetchBrandsManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          "Quản lý thương hiệu",
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
                  children: [Expanded(child: _buildBrandList(context))],
                ),
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _showBrandDialog(context, isEdit: false);
        },
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildBrandList(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
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
                child: BrandImagePicker(imageUrl: brand.image),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name ?? 'Không có tên',
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

  Widget _buildPopupMenu(BuildContext context, int brandIndex) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          _showBrandDialog(context, isEdit: true, brandIndex: brandIndex);
        } else if (value == 'delete') {
          _confirmDeleteBrand(context, brandIndex);
        }
      },
      color: Colors.white,
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

  void _showBrandDialog(
    BuildContext context, {
    required bool isEdit,
    int? brandIndex,
  }) {
    final brand = isEdit ? brands[brandIndex!] : null;
    TextEditingController nameController = TextEditingController(
      text: isEdit ? brand!.name ?? '' : '',
    );
    String? imageUrl = isEdit ? brand!.image : null;

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
                isEdit ? "Chỉnh sửa thương hiệu" : "Thêm thương hiệu",
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
                        labelText: "Tên thương hiệu",
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
                        SnackBar(
                          content: Text("Vui lòng nhập tên thương hiệu"),
                        ),
                      );
                      return;
                    }
                    try {
                      if (isEdit) {
                        final oldName = brand!.name ?? '';
                        if (oldName.isEmpty) {
                          throw Exception("Tên thương hiệu cũ không hợp lệ");
                        }
                        await apiAdminService.updateBrand(oldName, imageUrl!);
                        print("Đường dẫn ảnh mới: $imageUrl");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Cập nhật thương hiệu thành công"),
                          ),
                        );
                      } else {
                        await apiAdminService.createBrand(
                          nameController.text.trim(),
                          imageUrl!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Tạo thương hiệu thành công")),
                        );
                      }
                      await fetchBrandsManager();
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

  void _confirmDeleteBrand(BuildContext context, int brandIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa ${brands[brandIndex].name} không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiAdminService.deleteBrand(brands[brandIndex].name!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Xóa thương hiệu thành công")),
                  );
                  await fetchBrandsManager();
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
