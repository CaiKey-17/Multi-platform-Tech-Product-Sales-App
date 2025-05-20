import 'package:app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import cho SharedPreferences

class EditProfilePage extends StatefulWidget {
  final String fullName; // Thêm tham số fullName
  final String email; // Thêm tham số email

  const EditProfilePage({Key? key, required this.fullName, required this.email})
    : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  String token = "";
  String fullName = "";
  late ApiService apiService;

  String? _fullNameError;
  String? _emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    apiService = ApiService(Dio());

    _fullNameController.text = widget.fullName;
    _emailController.text = widget.email;

    _fullNameFocusNode.addListener(() {
      setState(() {});
    });

    _emailFocusNode.addListener(() {
      setState(() {});
    });

    _fullNameController.addListener(() {
      setState(() {
        _fullNameError =
            _fullNameController.text.trim().isEmpty
                ? "Vui lòng nhập họ tên"
                : null;
      });
    });

    _emailController.addListener(() {
      setState(() {
        _emailError = _validateEmail(_emailController.text.trim());
      });
    });
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return "Vui lòng nhập email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Email không hợp lệ!";
    }
    return null;
  }

  void _handleSave() async {
    setState(() {
      _isLoading = true;
    });
    print(_fullNameController.text.trim());
    bool isFullNameEmpty = _fullNameController.text.trim().isEmpty;
    bool isEmailEmpty = _emailController.text.trim().isEmpty;

    if (isFullNameEmpty || isEmailEmpty) {
      setState(() {
        _isLoading = false;
        if (isFullNameEmpty) {
          _fullNameError = "Vui lòng nhập họ tên";
        }
        if (isEmailEmpty) {
          _emailError = "Vui lòng nhập email";
        }
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      fetchChangeName(_fullNameController.text.trim());
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchChangeName(String name) async {
    setState(() => _isLoading = true);

    try {
      if (token != null && token.isNotEmpty) {
        await apiService.changeName(token, name);
        print("✅ Gửi API thành công");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', _fullNameController.text.trim());
      } else {
        print("⚠️ Token không tồn tại");
      }
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Cập nhật thông tin thành công",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        _isLoading = false;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "";
      token = prefs.getString('token') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Cập nhật thông tin",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _fullNameController,
                  focusNode: _fullNameFocusNode,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
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
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorText: _fullNameError,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                  onTapOutside: (event) {
                    _fullNameFocusNode.unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  enabled: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color:
                          _emailFocusNode.hasFocus ? Colors.blue : Colors.grey,
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color:
                          _emailFocusNode.hasFocus ? Colors.blue : Colors.black,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorText: _emailError,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                  onTapOutside: (event) {
                    _emailFocusNode.unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // Đã xử lý lỗi qua _emailError
                    }
                    return _validateEmail(value.trim());
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
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
                              "Lưu",
                              style: TextStyle(fontSize: screenWidth * 0.04),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }
}
