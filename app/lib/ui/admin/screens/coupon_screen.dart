import 'dart:math';
import 'package:app/globals/convert_money.dart';
import 'package:app/models/coupon_admin_info.dart';
import 'package:app/services/api_service.dart';
import 'package:app/ui/admin/screens/order_screen.dart';
import 'package:app/ui/admin/widgets/sidebar.dart';
import 'package:app/ui/product/product_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponScreen extends StatefulWidget {
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  bool isLoading = false;
  List<CouponAdminData> coupons = [];
  late ApiService apiService;
  String? token;

  final valueOptions = ["10,000", "20,000", "50,000", "100,000"];
  String? selectedValue;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController maxUsageController = TextEditingController();
  final TextEditingController minOrderValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    _loadToken();
    fetchCoupons();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        token = prefs.getString('token') ?? "";
        debugPrint('Token loaded for CouponScreen: $token');
      });
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi tải token từ SharedPreferences: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> fetchCoupons() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.listCoupon();
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        coupons = response.data;
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

  Future<void> addCoupon(
    int couponValue,
    int maxAllowedUses,
    int minOrderValue,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.addCoupon(
        couponValue,
        maxAllowedUses,
        minOrderValue,
      );
      Navigator.pop(context);

      await fetchCoupons();

      setState(() {
        isLoading = false;
        minOrderValueController.clear();
        maxUsageController.clear();
        selectedValue = null;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");

      setState(() {
        isLoading = false;
      });
      setState(() {
        minOrderValueController.clear();
        maxUsageController.clear();
        selectedValue = null;
      });

      Navigator.pop(context);
    }
  }

  Future<void> deleteCoupon(int id) async {
    try {
      final response = await apiService.deleteCoupon(id);
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SideBar(token: token ?? ''),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Quản lý phiếu giảm giá",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: 800,
                        child: _buildCouponTable(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _showCouponDialog(isEdit: false);
        },
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildCouponTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 16,
          columns: [
            DataColumn(
              label: Text('Mã', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text(
                'Trị giá ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Ngày tạo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Tối đa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Đã dùng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Giá trị tối thiểu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: coupons.map((coupon) {
            return DataRow(
              cells: [
                DataCell(Text(coupon.name)),
                DataCell(
                  Text(
                    "${ConvertMoney.currencyFormatter.format(coupon.couponValue)} ₫",
                  ),
                ),
                DataCell(Text(formatDate(coupon.createdAt))),
                DataCell(Text(coupon.maxAllowedUses.toString())),
                DataCell(Text(coupon.usedCount.toString())),
                DataCell(
                  Text(
                    "${ConvertMoney.currencyFormatter.format(coupon.minOrderValue)} ₫",
                  ),
                ),
              ],
              onLongPress: () => _showCouponOptions(coupon),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCouponOptions(CouponAdminData coupon) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.list_alt),
                title: Text("Xem các đơn hàng sử dụng"),
                textColor: Colors.blue,
                iconColor: Colors.blue,
                onTap: () {
                  debugPrint('Điều hướng đến OrderScreen với couponId: ${coupon.id}');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderScreen(couponId: coupon.id),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                textColor: Colors.red,
                iconColor: Colors.red,
                title: Text("Xóa"),
                onTap: () {
                  deleteCoupon(coupon.id);
                  setState(() {
                    coupons.removeWhere((c) => c.id == coupon.id);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showCouponDialog({required bool isEdit}) {
    final currencyFormatter = NumberFormat("#,##0", "vi_VN");
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? "Chỉnh sửa mã giảm giá" : "Thêm mã giảm giá",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: "Trị giá",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    value: selectedValue,
                    items: ["10,000", "20,000", "50,000", "100,000"]
                        .map(
                          (value) => DropdownMenuItem(
                            child: Text("$value ₫"),
                            value: value,
                          ),
                        )
                        .toList(),
                    onChanged: (value) => selectedValue = value,
                    validator: (value) =>
                        value == null ? "Vui lòng chọn giá trị" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: maxUsageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Số lần sử dụng tối đa",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Không được để trống';
                      }
                      int? parsed = int.tryParse(value);
                      if (parsed == null) return 'Phải là số';
                      if (parsed > 10) return 'Không được vượt quá 10';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: minOrderValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Giá trị đơn hàng tối thiểu",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      suffixText: 'đ',
                    ),
                    onChanged: (value) {
                      String newText = value.replaceAll(RegExp(r'[^\d]'), '');
                      if (newText.isEmpty) {
                        minOrderValueController.text = '';
                        return;
                      }
                      final formatted = currencyFormatter.format(
                        int.parse(newText),
                      );
                      minOrderValueController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Không được để trống';
                      final plainNumber = value.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      final parsed = int.tryParse(plainNumber);
                      if (parsed == null) return 'Phải là số';
                      final plainCouponValue = selectedValue!.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      final couponValue = int.tryParse(plainCouponValue);
                      if (couponValue != null && parsed <= couponValue) {
                        return 'Giá trị đơn hàng tối thiểu phải lớn hơn trị giá mã giảm giá';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Hủy",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final plainCouponValue = selectedValue!.replaceAll(
                              RegExp(r'[^\d]'),
                              '',
                            );
                            final couponValue = int.tryParse(plainCouponValue);
                            final minOrderValue = minOrderValueController.text
                                .replaceAll(RegExp(r'[^\d]'), '');
                            final minOrderValueInt = int.tryParse(
                              minOrderValue,
                            );
                            if (minOrderValueInt != null &&
                                couponValue != null &&
                                minOrderValueInt <= couponValue) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Giá trị đơn hàng tối thiểu phải lớn hơn trị giá mã giảm giá",
                                  ),
                                ),
                              );
                              return;
                            }
                            int c = int.parse(plainCouponValue);
                            int max = int.parse(maxUsageController.text);
                            int min = int.parse(minOrderValue);
                            addCoupon(c, max, min);
                          }
                        },
                        child: Text(
                          "Thêm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}