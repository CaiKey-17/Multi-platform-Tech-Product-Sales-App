import 'dart:async';
import 'package:app/models/resend_otp_request.dart';
import 'package:flutter/material.dart';
import 'package:app/models/valid_request.dart';
import 'package:app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpScreen extends StatefulWidget {
  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String email = "";
  String password = "";
  String address = "";
  String codes = "";
  String otp = "";
  String fullName = "";
  bool isButtonEnabled = false;
  late ApiService apiService;

  late Timer _timer;
  int _timeRemaining = 60;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    _loadUserData();
    _startTimer();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? "";
      password = prefs.getString('password') ?? "";
      address = prefs.getString('address') ?? "";
      codes = prefs.getString('codes') ?? "";
      fullName = prefs.getString('fullName') ?? "";
      print("Codes: ${codes}");
    });
  }

  Future<void> _clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('address');
    await prefs.remove('codes');
    await prefs.remove('fullName');

    setState(() {
      email = "";
      password = "";
      address = "";
      fullName = "";
      codes = "";
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  void _validateCode(String value) {
    setState(() {
      otp = value;
      isButtonEnabled = otp.length == 6;
    });
  }

  void _resendOtp() {
    if (_timeRemaining == 0) {
      setState(() {
        _timeRemaining = 60;
      });

      _startTimer();

      apiService.resendOtp(ResendOtpRequest(email: email)).then((response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.code == 200
                  ? "Mã OTP mới đã được gửi!"
                  : "Lỗi khi gửi lại mã OTP!",
            ),
            backgroundColor: response.code == 200 ? Colors.green : Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _verifyOtp() async {
    try {
      final response = await apiService.verifyOtp(
        ValidRequest(
          email: email,
          password: password,
          address: address,
          codes: codes,
          otp: otp,
          fullname: fullName,
        ),
      );
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

      _clearUserData();
      Navigator.pushReplacementNamed(context, "/login");
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? "Lỗi không xác định";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi không xác định: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
    }
  }

  String maskEmail(String email) {
    if (!email.contains("@")) return email;

    List<String> parts = email.split("@");
    String firstPart = parts[0];
    String domain = parts[1];

    String maskedFirstPart = firstPart[0] + '*' * (firstPart.length - 1);

    return "$maskedFirstPart@$domain";
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Xác minh",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 7,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "Chúng tôi đã gửi mã xác nhận qua email",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 10),

                        Text(
                          "${maskEmail(email)}",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    inactiveColor: Colors.grey.shade400,
                    selectedColor: Colors.blue.shade300,
                    activeColor: Colors.blue.shade900,
                  ),
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onChanged: _validateCode,
                ),

                Center(
                  child: Column(
                    children: [
                      _timeRemaining > 0
                          ? Text(
                            "Mã hết hạn sau: ${_formatTime(_timeRemaining)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          )
                          : Text(
                            "Mã đã hết hạn, vui lòng yêu cầu mã mới!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isButtonEnabled && _timeRemaining > 0
                            ? _verifyOtp
                            : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor:
                          (isButtonEnabled && _timeRemaining > 0)
                              ? Colors.blue
                              : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Xác nhận", style: TextStyle(fontSize: 18)),
                  ),
                ),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _timeRemaining == 0 ? _resendOtp : null,
                    child: Text(
                      "Bạn đã nhận mã chưa? Gửi lại",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _timeRemaining == 0 ? Colors.blue : Colors.grey,
                      ),
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
}
