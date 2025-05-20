import 'package:app/models/address.dart';
import 'package:app/models/user_info.dart';
import 'package:app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late ApiService apiService;
  List<AddressList> addresses_api = [];
  List<Map<String, dynamic>> addresses = [];
  int? indexSelected;
  bool isLoading = true;
  String token = "";
  List<Map<String, dynamic>> convertAddressListToMap(List<AddressList> input) {
    return input.map((address) {
      List<String> parts = address.address.split(',');
      String specificAddress = parts.isNotEmpty ? parts[0].trim() : '';
      String location =
          parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

      return {
        'id': address.id,
        'specificAddress': specificAddress,
        'location': location,
        'isDefault': address.status == 1 ? 'true' : 'false',
        'isCurrentDefault': address.status == 1 ? true : false,
      };
    }).toList();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      fetchAddresses();
    });
  }

  Future<void> fetchAddresses() async {
    try {
      final response = await apiService.getListAddress(token);
      setState(() {
        addresses_api = response;

        addresses = convertAddressListToMap(addresses_api);

        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    _loadUserData();
  }

  Map<String, Object> convertSingleAddress(AddressList address) {
    List<String> parts = address.address.split(',');
    String specificAddress = parts.isNotEmpty ? parts[0].trim() : '';
    String location = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

    return {
      'id': address.id!,
      'specificAddress': specificAddress,
      'location': location,
      'isDefault': 'false',
      'isCurrentDefault': false,
    };
  }

  void _addNewAddress(AddressList n) {
    final newAddress = convertSingleAddress(n);

    setState(() {
      addresses.add(newAddress);
    });
  }

  void _setDefaultAddress() async {
    setState(() {
      final selectedAddressIndex = addresses.indexWhere(
        (address) => address['isDefault'] == 'true',
      );

      if (selectedAddressIndex != -1) {
        for (var address in addresses) {
          address['isCurrentDefault'] = false;
        }
        addresses[selectedAddressIndex]['isCurrentDefault'] = true;
        setState(() {
          indexSelected = addresses[selectedAddressIndex]['id'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn một địa chỉ để đặt làm mặc định'),
          ),
        );
      }
    });

    if (indexSelected != -1) {
      try {
        final response = await apiService.chooseAddressDefault(
          token,
          indexSelected!,
        );
        try {
          UserInfo userInfo = await apiService.getUserInfo("Bearer $token");

          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('addresses', userInfo.addresses);
          await prefs.setStringList('codes', userInfo.codes);
        } catch (e) {
          print("Lỗi khi lấy thông tin người dùng: $e");
        }
      } catch (e) {
        print("Lỗi khi gọi API: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Địa chỉ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.star, color: Colors.white),
            onPressed: _setDefaultAddress,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address['specificAddress'] ??
                                    'Không có địa chỉ chi tiết',
                                style: TextStyle(color: Colors.black87),
                              ),
                              SizedBox(height: 2),
                              Text(
                                address['location'] ?? 'Không có địa điểm',
                                style: TextStyle(color: Colors.black87),
                              ),
                              if (address['isCurrentDefault'] == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Mặc định',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: address['isDefault'] == 'true',
                            onChanged: (value) {
                              setState(() {
                                for (var addr in addresses) {
                                  addr['isDefault'] = 'false';
                                }
                                address['isDefault'] = value.toString();
                              });
                            },
                            activeTrackColor: Colors.blue,
                            activeColor: Colors.white,
                            inactiveTrackColor: Colors.white,
                            inactiveThumbColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    AddressList newAddress = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAddressScreen(),
                      ),
                    );
                    if (newAddress != null) {
                      _addNewAddress(newAddress);
                    }
                  },
                  icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                  label: Text(
                    'Thêm Địa Chỉ Mới',
                    style: TextStyle(color: Colors.blue),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.blue),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
