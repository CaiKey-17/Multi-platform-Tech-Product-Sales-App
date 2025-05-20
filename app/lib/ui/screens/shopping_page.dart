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

class ShoppingCartPage extends StatefulWidget {
  final bool isFromTab;

  const ShoppingCartPage({super.key, this.isFromTab = true});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late ApiService apiService;
  late CartRepository cartRepository;
  late CartService cartService;
  List<CartInfo> cartItems = [];
  bool isLoading = true;
  String token = "";
  int? userId;
  int orderId = -1;

  @override
  void didPopNext() {
    _loadUserData();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    apiService = ApiService(Dio());
    cartRepository = CartRepository(apiService);
    cartService = CartService(cartRepository: cartRepository);
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      userId = prefs.getInt('userId') ?? -1;
    });
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      List<CartInfo> response;
      if (token.isNotEmpty && userId == -1) {
        response = await apiService.getItemInCart(token: token);
        print("Sử dụng token");
      } else if (token == "" && userId != -1) {
        response = await apiService.getItemInCart(id: userId);
        print("Sử dụng userID");
      } else {
        response = await apiService.getItemInCart(token: token, id: userId);
      }
      setState(() {
        cartItems = response;
        orderId = cartItems.isNotEmpty ? cartItems[0].orderId : -1;
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

  void _incrementQuantity(int index, int color, int variant, int id) async {
    bool check = await cartService.addMoreToCart(
      productID: variant,
      colorId: color,
      id: id,
      token: token,
      context: context,
    );

    if (check) {
      setState(() {
        cartItems[index].quantity++;
      });
    }
  }

  void _decrementQuantity(
    int index,
    int variant,
    int order,
    int userId,
    int fkColorId,
  ) async {
    if (cartItems[index].quantity > 1) {
      bool check = await cartService.minusMoreToCart(
        productId: variant,
        orderId: order,
        id: variant,
        userID: userId,
        colorId: fkColorId,
        context: context,
      );
      if (check) {
        setState(() {
          cartItems[index].quantity--;
        });
      }
    }
  }

  void _removeItem(int index, int orderDetailId, int id) async {
    bool check = await cartService.deleteToCart(
      orderDetailId: orderDetailId,
      context: context,
    );
    if (check) {
      setState(() {
        cartItems.removeAt(index);
      });

      Provider.of<CartProvider>(context, listen: false).removeItem(id);
    }
  }

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int index,
    int orderDetailId,
    int productId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Xác nhận xoá',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn muốn xoá sản phẩm này?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _removeItem(index, orderDetailId, orderDetailId);
                      },
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeSelectedItems() async {
    final selectedItems =
        cartItems
            .asMap()
            .entries
            .where((entry) => entry.value.selected)
            .toList();

    final itemsToRemove =
        selectedItems.isNotEmpty
            ? selectedItems
            : cartItems.asMap().entries.toList();

    Provider.of<CartProvider>(context, listen: false).printCartItems();

    for (int i = itemsToRemove.length - 1; i >= 0; i--) {
      final index = itemsToRemove[i].key;
      final item = itemsToRemove[i].value;
      print(index);

      print(item.orderDetailId);

      _removeItem(index, item.orderDetailId, item.orderDetailId);
    }
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    bool hasSelectedItems = cartItems.any((item) => item.selected);

    String message =
        hasSelectedItems
            ? "Bạn muốn xoá các sản phẩm đã chọn?"
            : "Bạn muốn xoá toàn bộ giỏ hàng?";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Xác nhận xoá",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _removeSelectedItems();
                      },
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = widget.isFromTab ? 75 : 35;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E7E7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
            widget.isFromTab
                ? null
                : IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),

        title: const Text('Giỏ hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showDeleteAllConfirmation(context),
          ),
        ],
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
                              Checkbox(
                                value: item.selected,
                                activeColor: Colors.blue,
                                onChanged:
                                    (value) => _toggleSelection(index, value),
                              ),
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
                                  child: Image.network(
                                    item.image ?? '',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) {
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

                                          Container(
                                            height: 30,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap:
                                                      () => _decrementQuantity(
                                                        index,
                                                        item.fkProductId,
                                                        item.orderId,
                                                        userId!,
                                                        item.fkColorId,
                                                      ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                SizedBox(
                                                  width: 16,
                                                  child: Center(
                                                    child: Text(
                                                      item.quantity.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                GestureDetector(
                                                  onTap:
                                                      () => _incrementQuantity(
                                                        index,
                                                        item.fkColorId,
                                                        item.fkProductId,
                                                        item.productId,
                                                      ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
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
                        Positioned(
                          right: -6,
                          top: -6,
                          child: IconButton(
                            onPressed:
                                () => _showDeleteConfirmation(
                                  context,
                                  index,
                                  item.orderDetailId,
                                  item.productId,
                                ),
                            icon: const Icon(Icons.close, size: 14),
                            color: Colors.grey.shade600,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      bottomNavigationBar: Container(
        padding:
            widget.isFromTab
                ? EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 80)
                : EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${ConvertMoney.currencyFormatter.format(totalPrice)} VNĐ",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 11, 79, 134),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (orderId == -1) {
                  print("orderId chưa hợp lệ");
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentConfirmationScreen(
                          orderId: orderId,
                          cartItems: cartItems,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8192ae),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Thanh toán"),
            ),
          ],
        ),
      ),
    );
  }
}
