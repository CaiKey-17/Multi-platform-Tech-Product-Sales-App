import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue[700]),
      home: UserInfoScreen(),
    );
  }
}

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _specificAddressController =
      TextEditingController();

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    final url = 'https://vn-public-apis.fpo.vn/provinces/getAll?limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _provinces = data['data']['data'];
        });
      } else {
        throw Exception('Không thể tải danh sách tỉnh/thành phố');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy tỉnh: $e');
    }
  }

  Future<void> _fetchDistricts(String provinceCode) async {
    final url =
        'https://vn-public-apis.fpo.vn/districts/getByProvince?provinceCode=$provinceCode&limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _districts = data['data']['data'];
          _wards.clear();
          _selectedDistrict = null;
          _selectedWard = null;
        });
      } else {
        throw Exception('Không thể tải danh sách quận/huyện');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy quận/huyện: $e');
    }
  }

  Future<void> _fetchWards(String districtCode) async {
    final url =
        'https://vn-public-apis.fpo.vn/wards/getByDistrict?districtCode=$districtCode&limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _wards = data['data']['data'];
          _selectedWard = null;
        });
      } else {
        throw Exception('Không thể tải danh sách xã/phường');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy xã/phường: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          "Thông tin người dùng",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField("Họ và tên", nameController, Icons.person),
              _buildTextField(
                "Số điện thoại",
                phoneController,
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                "Email",
                emailController,
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              _buildSectionTitle("ĐỊA CHỈ MẶC ĐỊNH"),
              _buildDropdown(
                label: "Tỉnh/Thành phố",
                value: _selectedProvince,
                items: _provinces,
                onChanged: (value) {
                  setState(() {
                    _selectedProvince = value;
                    _fetchDistricts(value!);
                  });
                },
              ),
              _buildDropdown(
                label: "Quận/Huyện",
                value: _selectedDistrict,
                items: _districts,
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                    _fetchWards(value!);
                  });
                },
              ),
              _buildDropdown(
                label: "Xã/Phường",
                value: _selectedWard,
                items: _wards,
                onChanged: (value) {
                  setState(() {
                    _selectedWard = value;
                  });
                },
              ),
              TextFormField(
                controller: _specificAddressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ cụ thể',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Xử lý xác nhận
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Xác nhận",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items.map((item) {
              return DropdownMenuItem<String>(
                value: item['code'],
                child: Text(item['name']),
              );
            }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blue[700],
        ),
      ),
    );
  }
}
