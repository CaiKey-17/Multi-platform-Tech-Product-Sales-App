import 'dart:convert';
import 'package:app/keys/shipping.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateAddressScreen extends StatefulWidget {
  final String currentAddress;
  UpdateAddressScreen({required this.currentAddress});

  @override
  _UpdateAddressScreenState createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  String? fullAddress;
  String codes = "";

  TextEditingController _specificAddressController = TextEditingController();

  final _specificAddressFocusNode = FocusNode();

  final _provinceFocusNode = FocusNode();
  final _districtFocusNode = FocusNode();
  final _wardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    String current = widget.currentAddress;

    if (current == 'Chưa có địa chỉ') {
      _specificAddressController = TextEditingController(text: '');
    } else {
      List<String> parts = current.split(',');
      String specificAddress = parts.isNotEmpty ? parts[0].trim() : '';
      _specificAddressController = TextEditingController(text: specificAddress);
    }

    fetchProvinces();

    _specificAddressFocusNode.addListener(() {
      setState(() {});
    });
    _provinceFocusNode.addListener(() {
      setState(() {});
    });
    _districtFocusNode.addListener(() {
      setState(() {});
    });
    _wardFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> fetchProvinces() async {
    Shipping shipping = new Shipping();
    final url = Uri.parse(
      "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/province",
    );
    final response = await http.get(url, headers: {"Token": shipping.apiKey});
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        provinces = data['data'];
      });
    }
  }

  Future<void> fetchDistricts(int provinceId) async {
    Shipping shipping = new Shipping();
    final url = Uri.parse(
      "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/district",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "Token": shipping.apiKey},
      body: jsonEncode({"province_id": provinceId}),
    );

    print("Response Districts: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        districts = data['data'] ?? [];
        selectedDistrict = null;
        wards = [];
      });
    } else {
      print("Lỗi khi tải danh sách quận/huyện");
    }
  }

  Future<void> fetchWards(int districtId) async {
    Shipping shipping = new Shipping();

    final url = Uri.parse(
      "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/ward",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "Token": shipping.apiKey},
      body: jsonEncode({"district_id": districtId}),
    );

    print("Response Wards: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        wards = data['data'] ?? [];
        selectedWard = null;
      });
    } else {
      print("Lỗi khi tải danh sách phường/xã");
    }
  }

  void getNameFromIds(String idString) async {
    List<String> ids = idString.split(',');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('code', idString);

    if (ids.length != 3) {
      print("Invalid ID string");
      return;
    }

    String wardId = ids[0].trim();
    String districtId = ids[1].trim();
    String provinceId = ids[2].trim();

    String provinceName = getProvinceName(provinceId);
    String districtName = getDistrictName(districtId);

    String wardName = getWardName(wardId);

    fullAddress =
        " ${_specificAddressController.text}, $wardName, $districtName, $provinceName";

    Navigator.pop(context, fullAddress);
  }

  String getProvinceName(String provinceId) {
    var province = provinces.firstWhere(
      (element) => element['ProvinceID'].toString() == provinceId,
      orElse: () => null,
    );
    return province != null ? province['ProvinceName'] : "Không tìm thấy tỉnh";
  }

  String getDistrictName(String districtId) {
    var district = districts.firstWhere(
      (element) => element['DistrictID'].toString() == districtId,
      orElse: () => null,
    );
    return district != null ? district['DistrictName'] : "Không tìm thấy huyện";
  }

  String getWardName(String wardId) {
    var ward = wards.firstWhere(
      (element) => element['WardCode'].toString() == wardId,
      orElse: () => null,
    );
    return ward != null ? ward['WardName'] : "Không tìm thấy xã";
  }

  void _saveAddress() {
    if (selectedProvince == null ||
        selectedDistrict == null ||
        selectedWard == null) {
      Fluttertoast.showToast(msg: "Vui lòng chọn đầy đủ địa chỉ!");
      return;
    }

    setState(() {
      codes = "$selectedWard,$selectedDistrict,$selectedProvince";

      if (codes != null) {
        getNameFromIds(codes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật địa chỉ", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue, // Giữ nguyên màu AppBar
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white, // Đặt màu nền thành trắng
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              focusNode: _provinceFocusNode,
              decoration: InputDecoration(
                labelText: 'Chọn tỉnh/thành',
                labelStyle: TextStyle(
                  color:
                      _provinceFocusNode.hasFocus ? Colors.blue : Colors.black,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              value: selectedProvince,
              items:
                  provinces.map((province) {
                    return DropdownMenuItem(
                      value: province['ProvinceID'].toString(),
                      child: Text(
                        province['ProvinceName'],
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProvince = value.toString();
                  fetchDistricts(int.parse(value.toString()));
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn tỉnh/thành';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              focusNode: _districtFocusNode,
              decoration: InputDecoration(
                labelText: 'Chọn quận/huyện',
                labelStyle: TextStyle(
                  color:
                      _districtFocusNode.hasFocus ? Colors.blue : Colors.black,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              value: selectedDistrict,
              items:
                  districts.map((district) {
                    return DropdownMenuItem(
                      value: district['DistrictID'].toString(),
                      child: Text(
                        district['DistrictName'],
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value.toString();
                  fetchWards(int.parse(value.toString()));
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn quận/huyện';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              focusNode: _wardFocusNode,
              decoration: InputDecoration(
                labelText: 'Chọn phường/xã',
                labelStyle: TextStyle(
                  color: _wardFocusNode.hasFocus ? Colors.blue : Colors.black,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              value: selectedWard,
              items:
                  wards.map((ward) {
                    return DropdownMenuItem(
                      value: ward['WardCode'].toString(),
                      child: Text(ward['WardName']),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWard = value.toString();
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn phường/xã';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _specificAddressController,
              focusNode: _specificAddressFocusNode,
              decoration: InputDecoration(
                labelText: 'Địa chỉ cụ thể',
                labelStyle: TextStyle(
                  color:
                      _specificAddressFocusNode.hasFocus
                          ? Colors.blue
                          : Colors.black,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onTapOutside: (event) {
                _specificAddressFocusNode.unfocus();
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text(
                "Lưu địa chỉ",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _specificAddressController.dispose();
    _specificAddressFocusNode.dispose();
    _provinceFocusNode.dispose();
    _districtFocusNode.dispose();
    _wardFocusNode.dispose();
    super.dispose();
  }
}
