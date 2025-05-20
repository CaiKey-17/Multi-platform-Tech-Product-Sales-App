import 'dart:convert';
import 'package:app/keys/shipping.dart';
import 'package:app/models/address.dart';
import 'package:app/models/address_response.dart';
import 'package:app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _specificAddressController =
      TextEditingController();
  final _addressController = TextEditingController();
  String token = "";
  int? userId;
  late ApiService apiService;

  bool _isDefaultAddress = false;
  bool _isLoading = false;

  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  String? fullAddress;
  String codes = "";

  String? _selectedProvinceCode;
  String? _selectedDistrictCode;

  final _specificAddressFocusNode = FocusNode();

  final _provinceFocusNode = FocusNode();
  final _districtFocusNode = FocusNode();
  final _wardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    _loadUserData();

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

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      userId = prefs.getInt('userId') ?? -1;
      fetchProvinces();
    });
  }

  Future<void> _addAddress() async {
    if (selectedProvince == null ||
        selectedDistrict == null ||
        selectedWard == null) {
      Fluttertoast.showToast(msg: "Vui lòng chọn đầy đủ địa chỉ");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    setState(() {
      codes = "$selectedWard,$selectedDistrict,$selectedProvince";
      if (codes != null) {
        getNameFromIds(codes);
      }
    });

    try {
      AddressList addressList = new AddressList.noId(
        address: fullAddress!,
        codes: codes,
        userId: userId!,
        status: token == "" ? 1 : 0,
      );
      final response = await apiService.addAddress(addressList);
      AddressResponse addressResponse = response;
      AddressList a = addressResponse.data;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${response.message}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: "Đóng",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, a);
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getNameFromIds(String idString) {
    List<String> ids = idString.split(',');

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

    setState(() {
      fullAddress =
          "${_specificAddressController.text}, $wardName, $districtName, $provinceName";

      print(fullAddress);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Đặt màu nền thành trắng
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          token == "" ? 'Chọn địa chỉ' : 'Địa chỉ mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        elevation: 1,
      ),
      body: Container(
        color: Colors.white, // Giữ lại để đảm bảo tính nhất quán
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              DropdownButtonFormField(
                focusNode: _provinceFocusNode,
                decoration: InputDecoration(
                  labelText: 'Chọn tỉnh/thành',
                  labelStyle: TextStyle(
                    color:
                        _provinceFocusNode.hasFocus
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
                dropdownColor: Colors.white,
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
                        _districtFocusNode.hasFocus
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
                dropdownColor: Colors.white,
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
                dropdownColor: Colors.white,
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addAddress,
                child:
                    _isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : Text(
                          'HOÀN THÀNH',
                          style: TextStyle(color: Colors.white),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _specificAddressController.dispose();
    _addressController.dispose();
    _specificAddressFocusNode.dispose();
    _provinceFocusNode.dispose();
    _districtFocusNode.dispose();
    _wardFocusNode.dispose();
    super.dispose();
  }
}
