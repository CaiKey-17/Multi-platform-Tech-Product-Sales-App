import 'dart:convert';
import 'package:app/keys/shipping.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';
import '../../models/register_request.dart';
import '../../services/api_service.dart';
import '../../models/register_response.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreeToTerms = false;
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _specificAddressController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  String? fullAddress;
  String codes = "";

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _specificAddressFocusNode = FocusNode();
  final _provinceFocusNode = FocusNode();
  final _districtFocusNode = FocusNode();
  final _wardFocusNode = FocusNode();

  String? _emailError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    fetchProvinces();

    _fullNameFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
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

    _emailController.addListener(() {
      setState(() {
        _emailError = _validateEmail(_emailController.text.trim());
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _confirmPasswordError = _validateConfirmPassword(
          _confirmPasswordController.text.trim(),
        );
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _confirmPasswordError = _validateConfirmPassword(
          _confirmPasswordController.text.trim(),
        );
      });
    });
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

  Future<void> _register() async {
    if (selectedProvince == null ||
        selectedDistrict == null ||
        selectedWard == null) {
      Fluttertoast.showToast(msg: "Vui lòng chọn đầy đủ địa chỉ");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String fullName = _fullNameController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Email không hợp lệ");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập mật khẩu");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      codes = "$selectedWard,$selectedDistrict,$selectedProvince";
      if (codes != null) {
        getNameFromIds(codes);
      }
    });

    final dio = Dio();
    final apiService = ApiService(dio);

    try {
      print("Codesss: ${codes}");

      final request = RegisterRequest(
        email: email,
        password: password,
        address: fullAddress!,
        fullname: fullName,
        codes: codes,
      );

      final response = await apiService.register(request);

      if (response.code == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setString('address', fullAddress!);
        await prefs.setString('fullName', fullName);
        await prefs.setString('codes', codes);

        Navigator.pushReplacementNamed(context, "/otp");
        Fluttertoast.showToast(msg: response.message);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      if (e is DioException) {
        Fluttertoast.showToast(
          msg: e.response?.data['message'] ?? "Lỗi server",
        );
      } else {
        Fluttertoast.showToast(msg: "Lỗi kết nối đến server: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    print(
      "Response Districts: ${utf8.decode(response.bodyBytes)}",
    ); // Debug API UTF-8

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

    print(
      "Response Wards: ${utf8.decode(response.bodyBytes)}",
    ); // Debug API UTF-8

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

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Email không hợp lệ!";
    }
    return null;
  }

  String? _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return null;
    }
    if (confirmPassword != _passwordController.text.trim()) {
      return "Mật khẩu không khớp";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Text(
              "Chào bạn\nĐăng ký ngay!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.25,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Tạo tài khoản mới",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.text,
                        focusNode: _fullNameFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color:
                                _fullNameFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          labelText: 'Họ tên',
                          labelStyle: TextStyle(
                            color:
                                _fullNameFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.black,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onTapOutside: (event) {
                          _fullNameFocusNode.unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color:
                                _emailFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          labelText: 'Địa chỉ Email',
                          labelStyle: TextStyle(
                            color:
                                _emailFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.black,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          errorText: _emailError,
                        ),
                        onTapOutside: (event) {
                          _emailFocusNode.unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập email của bạn';
                          }
                          return _validateEmail(value.trim());
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color:
                                _passwordFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          labelText: 'Mật khẩu',
                          labelStyle: TextStyle(
                            color:
                                _passwordFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.black,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color:
                                  _passwordFocusNode.hasFocus
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        onTapOutside: (event) {
                          _passwordFocusNode.unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        focusNode: _confirmPasswordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color:
                                _confirmPasswordFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                          labelText: 'Xác nhận mật khẩu',
                          labelStyle: TextStyle(
                            color:
                                _confirmPasswordFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.black,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color:
                                  _confirmPasswordFocusNode.hasFocus
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          errorText: _confirmPasswordError,
                        ),
                        onTapOutside: (event) {
                          _confirmPasswordFocusNode.unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          return _validateConfirmPassword(value.trim());
                        },
                      ),
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
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
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
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
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
                            color:
                                _wardFocusNode.hasFocus
                                    ? Colors.blue
                                    : Colors.black,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
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
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onTapOutside: (event) {
                          _specificAddressFocusNode.unfocus();
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "Tôi đồng ý với Điều khoản và Chính sách bảo mật.",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_agreeToTerms && !_isLoading)
                                  ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      await _register();
                                      setState(() => _isLoading = false);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Vui lòng kiểm tra lại thông tin!",
                                      );
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor:
                                (_agreeToTerms && !_isLoading)
                                    ? Colors.blue
                                    : Colors.grey[300],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
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
                                    "Đăng ký",
                                    style: TextStyle(fontSize: 18),
                                  ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Đã có tài khoản? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: "Đăng nhập",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specificAddressController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _specificAddressFocusNode.dispose();
    _provinceFocusNode.dispose();
    _districtFocusNode.dispose();
    _wardFocusNode.dispose();
    super.dispose();
  }
}
