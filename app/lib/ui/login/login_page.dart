import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../models/login_request.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late ApiService _apiService;

  bool _obscureText = true;
  bool _isLoading = false;
  String? _passwordError;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String? _emailError;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(Dio());
    _loadSavedLogin();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });

    _emailFocusNode.addListener(() {
      setState(() {});
    });

    _passwordFocusNode.addListener(() {
      setState(() {});
    });

    _emailController.addListener(() {
      setState(() {
        _emailError = _validateEmail(_emailController.text.trim());
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _passwordError = null;
      });
    });
  }

  void _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      _autoLogin(savedEmail, savedPassword);
    }
  }

  void _autoLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = LoginRequest(
        username: email.trim(),
        password: password.trim(),
      );

      final response = await _apiService.login(request);

      if (response.code == 200) {
        onLoginSuccess(response.token.toString(), response.role.toString());
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng nhập tự động thất bại, vui lòng thử lại"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi kết nối đến server")));
    }
  }

  void onLoginSuccess(String token, String role) async {
    final authRepo = AuthRepository();

    if (role == 'ROLE_CUSTOMER') {
      bool success = await authRepo.fetchUserInfo(token, role);
      if (success) {
        print("Lấy thông tin người dùng thành công!");
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
    }
    if (role == 'ROLE_ADMIN') {
      bool success = await authRepo.fetchAdminInfo(token, role);
      if (success) {
        print("Lấy thông tin admin thành công!");
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/manager",
          (route) => false,
        );
      }
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

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _passwordError = null;
      _emailError = null;
    });

    bool isEmailEmpty = _emailController.text.trim().isEmpty;
    bool isPasswordEmpty = _passwordController.text.trim().isEmpty;

    if (isEmailEmpty || isPasswordEmpty) {
      setState(() {
        _isLoading = false;
        if (isEmailEmpty) {
          _emailError = "Vui lòng nhập email";
        }
        if (isPasswordEmpty) {
          _passwordError = "Bạn chưa nhập mật khẩu";
        }
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        final request = LoginRequest(
          username: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final response = await _apiService.login(request);

        setState(() {
          _isLoading = false;
        });

        if (response.code == 200) {
          onLoginSuccess(response.token.toString(), response.role.toString());
        } else if (response.code == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")),
          );
        } else if (response.code == 403) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Tài khoản đã bị cấm")));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (e is DioException) {
          if (e.response?.statusCode == 401) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")),
            );
          } else if (e.response?.statusCode == 403) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Tài khoản đã bị cấm")));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Lỗi kết nối đến server")));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi không xác định")));
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF64B5F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: SizedBox(
              width: screenWidth * 0.8,
              child: Text(
                "Chào bạn\nĐăng nhập ngay!",
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            height: screenHeight * 0.75,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: 20,
            ),
            margin: EdgeInsets.only(top: screenHeight * 0.25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      "Chào mừng bạn trở lại",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color:
                            _emailFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.grey,
                      ),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color:
                            _emailFocusNode.hasFocus
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
                      errorText: _emailError,
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    onTapOutside: (event) {
                      _emailFocusNode.unfocus();
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      return _validateEmail(value.trim());
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    obscureText: _obscureText,
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color:
                              _passwordFocusNode.hasFocus
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      errorText: _passwordError,
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    onTapOutside: (event) {
                      _passwordFocusNode.unfocus();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: Colors.blue, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
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
                                "Đăng Nhập",
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/main");
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(color: Colors.blue),
                      ),
                      child: Text(
                        "Mua hàng không cần đăng nhập",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Text(
                      "Đăng nhập với",
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        'assets/images/facebook.png',
                        'Facebook',
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      _buildSocialButton('assets/images/google.webp', 'Google'),
                      SizedBox(width: screenWidth * 0.04),
                      _buildSocialButton('assets/images/apple.png', 'Apple'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Bạn chưa có tài khoản? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                          children: [
                            TextSpan(
                              text: "Đăng ký",
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSocialButton(String imagePath, String name) {
    return GestureDetector(
      onTap: () {
        debugPrint("Đã nhấn vào $name");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Đã nhấn vào $name")));
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Image.asset(imagePath, width: 40, height: 40),
        ),
      ),
    );
  }
}
