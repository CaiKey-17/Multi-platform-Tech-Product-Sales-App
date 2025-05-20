import 'package:app/globals/convert_money.dart';
import 'package:app/models/cart_info.dart';
import 'package:app/repositories/cart_repository.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/order/payment_process.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailOrderPage extends StatefulWidget {
  final int orderId;

  const DetailOrderPage({super.key, required this.orderId});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  late ApiService apiService;
  late CartRepository cartRepository;
  late CartService cartService;
  List<CartInfo> cartItems = [];
  bool isLoading = true;

  @override
  void didPopNext() {}

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1));
      List<CartInfo> response;
      response = await apiService.getItemInCartDetail(orderId: widget.orderId);

      setState(() {
        cartItems = response;
        isLoading = false;
      });
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleSelection(int index, bool? value) {
    setState(() {
      cartItems[index].selected = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E7E7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Đang tải...",
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                  ],
                ),
              )
              : cartItems.isEmpty
              ? Container(
                color: const Color.fromARGB(255, 239, 239, 239),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 48,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Giỏ hàng trống",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),

                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child:
                                      (item.image == null ||
                                              item.image!.isEmpty)
                                          ? Image.asset(
                                            'assets/images/default.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 150,
                                          )
                                          : Image.network(
                                            item.image,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 150,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.asset(
                                                'assets/images/default.jpg',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 150,
                                              );
                                            },
                                          ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 12,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nameVariant,
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        (item.colorName?.trim().isEmpty ?? true)
                                            ? 'Mặc định'
                                            : item.colorName!,
                                        style: TextStyle(
                                          fontSize: 11,

                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${ConvertMoney.currencyFormatter.format(item.price)} đ",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  "${ConvertMoney.currencyFormatter.format(item.originalPrice)} đ",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                  ),

                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),

                                          Center(
                                            child: Text(
                                              "Số lượng: " +
                                                  item.quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
    );
  }
}
