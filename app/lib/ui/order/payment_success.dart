import 'package:app/globals/convert_money.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double? total;
  final String? tempId;

  const PaymentSuccessScreen({super.key, this.total, this.tempId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String generateTransactionId() {
    final now = DateTime.now();
    return "${now.microsecondsSinceEpoch}";
  }

  @override
  Widget build(BuildContext context) {
    String temp = ConvertMoney.currencyFormatter.format(widget.total) + " đ";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text(
                "Thanh toán thành công!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Cảm ơn bạn đã mua hàng. Đơn hàng của bạn đang được xử lý.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _transactionDetailRow(
                      "Mã giao dịch:",
                      "#${generateTransactionId()}",
                    ),
                    _transactionDetailRow(
                      "Ngày giao dịch:",
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    ),

                    _transactionDetailRow("Số tiền: ", temp),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (widget.tempId!.startsWith('T')) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                  }
                  Navigator.pushReplacementNamed(context, "/main");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Về trang chủ",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
