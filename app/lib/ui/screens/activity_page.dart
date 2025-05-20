import 'package:app/globals/convert_money.dart';
import 'package:app/providers/user_points_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/order/detail_order_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> pendingOrders = [];
  List<Map<String, dynamic>> deliveringOrders = [];
  List<Map<String, dynamic>> deliveredOrders = [];

  bool isLoading = false;
  String token = "";
  late ApiService apiService;

  late TabController _tabController;

  final PagingController<int, Map<String, dynamic>> _pendingController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Map<String, dynamic>> _deliveringController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Map<String, dynamic>> _deliveredController =
      PagingController(firstPageKey: 0);

  static const int _pageSize = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    apiService = ApiService(Dio());

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _refreshCurrentTab(_tabController.index);
      }
    });

    _loadUserData();
  }

  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0:
        fetchPendingOrders(token);
        _pendingController.refresh();
        break;
      case 1:
        fetchOrderingOrders(token);
        _deliveringController.refresh();
        break;
      case 2:
        fetchOrderedOrders(token);
        _deliveredController.refresh();
        break;
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
    fetchPendingOrders(token);
    fetchOrderingOrders(token);
    fetchOrderedOrders(token);

    _pendingController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey, _pendingController, pendingOrders);
    });
    _deliveringController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey, _deliveringController, deliveringOrders);
    });

    _deliveredController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey, _deliveredController, deliveredOrders);
    });
  }

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy, HH:mm').format(dateTime);
  }

  Future<void> fetchPendingOrders(String token) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.findPendingOrdersByCustomer(token);

      final List<Map<String, dynamic>> transformed =
          response.map((order) {
            return {
              "id": order["orderId"],
              "status": order["status"],
              "image": order["firstProductImage"],
              "name": order["firstProductName"],
              "time": formatDate(order["createdAt"]),
              "details": "",
              "quantity": order["totalItems"],
              "totalPrice": ConvertMoney.currencyFormatter.format(
                order["total"],
              ),
            };
          }).toList();

      setState(() {
        pendingOrders = transformed;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchOrderedOrders(String token) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.findDeliveredOrdersByCustomer(token);

      final List<Map<String, dynamic>> transformed =
          response.map((order) {
            return {
              "id": order["orderId"],
              "status": order["status"],
              "image": order["firstProductImage"],
              "name": order["firstProductName"],
              "time": formatDate(order["createdAt"]),
              "details": "",
              "quantity": order["totalItems"],
              "totalPrice": ConvertMoney.currencyFormatter.format(
                order["total"],
              ),
            };
          }).toList();

      setState(() {
        deliveredOrders = transformed;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchOrderingOrders(String token) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.findDeliveringOrdersByCustomer(token);

      final List<Map<String, dynamic>> transformed =
          response.map((order) {
            return {
              "id": order["orderId"],
              "status": order["status"],
              "image": order["firstProductImage"],
              "name": order["firstProductName"],
              "time": formatDate(order["createdAt"]),
              "details": "",
              "quantity": order["totalItems"],
              "totalPrice": ConvertMoney.currencyFormatter.format(
                order["total"],
              ),
            };
          }).toList();

      setState(() {
        deliveringOrders = transformed;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // final List<Map<String, dynamic>> pendingOrders = [
  //   {
  //     "status": "Chờ xác nhận",
  //     "image": "assets/images/dienthoai.webp",
  //     "name": "Ổ cắm điện đa năng HONJIANDA Sạc nhanh 1",
  //     "time": "23/02/2025, 17:01",
  //     "details": "0448, 8 lỗ cắm, 1.8 mét",
  //     "quantity": 1,
  //     "totalPrice": 99000,
  //   },
  //   {
  //     "status": "Chờ xác nhận",
  //     "image": "assets/images/dienthoai.webp",
  //     "name": "Ổ cắm điện đa năng HONJIANDA Sạc nhanh 2",
  //     "time": "23/02/2025, 17:01",
  //     "details": "0448, 8 lỗ cắm, 1.8 mét",
  //     "quantity": 1,
  //     "totalPrice": 99000,
  //   },
  //   {
  //     "status": "Chờ xác nhận",
  //     "image": "assets/images/dienthoai.webp",
  //     "name": "Ổ cắm điện đa năng HONJIANDA Sạc nhanh 3",
  //     "time": "23/02/2025, 17:01",
  //     "details": "0448, 8 lỗ cắm, 1.8 mét",
  //     "quantity": 1,
  //     "totalPrice": 99000,
  //   },
  // ];

  // final List<Map<String, dynamic>> deliveringOrders = [
  //   {
  //     "store": "Tech Store",
  //     "status": "Chờ giao hàng",
  //     "image": "assets/images/dienthoai.webp",
  //     "name": "Bàn phím cơ RGB gaming",
  //     "time": "23/02/2025",
  //     "details": "Switch Brown, kết nối USB",
  //     "quantity": 1,
  //     "totalPrice": 499000,
  //   },
  // ];

  void _handleOrder(int orderId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.cancelToCart(orderId);

      if (response.data != null && response.data is int) {
        if (response.data > 0) {
          Provider.of<UserPointsProvider>(context, listen: false).points =
              response.data;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('points', response.data);
        }
      } else {
        print("Invalid response data");
      }

      Fluttertoast.showToast(
        msg: "Hủy đơn thành công!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      await fetchPendingOrders(token);
      await fetchOrderingOrders(token);
      await fetchOrderedOrders(token);

      _pendingController.refresh();
      _deliveringController.refresh();
      _deliveredController.refresh();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại")),
      );
    }
  }

  void _handleConfirmOrder(int orderId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.received(orderId);
      if (response.data != null && response.data is int) {
        if (response.data > 0) {
          int currentPoints =
              Provider.of<UserPointsProvider>(context, listen: false).points;

          int newPoints = currentPoints + response.data as int;

          Provider.of<UserPointsProvider>(context, listen: false).points =
              newPoints;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('points', newPoints);
        }
      } else {
        print("Invalid response data");
      }
      Fluttertoast.showToast(
        msg: "Chúng tôi xin chân thành cảm ơn bạn!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      await fetchPendingOrders(token);
      await fetchOrderingOrders(token);
      await fetchOrderedOrders(token);

      _pendingController.refresh();
      _deliveringController.refresh();
      _deliveredController.refresh();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại")),
      );
    }
  }

  // Hàm lấy dữ liệu phân trang
  Future<void> _fetchOrders(
    int pageKey,
    PagingController<int, Map<String, dynamic>> controller,
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final startIndex = pageKey * _pageSize;
      final endIndex =
          (startIndex + _pageSize) > orders.length
              ? orders.length
              : (startIndex + _pageSize);
      final newItems = orders.sublist(startIndex, endIndex);

      final isLastPage =
          newItems.length < _pageSize || endIndex == orders.length;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pendingController.dispose();
    _deliveringController.dispose();
    _deliveredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Hoạt động"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          ),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () {
              print("Nhấn vào thông báo!");
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.blue,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                indicatorColor: Colors.blue,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(text: "Chờ xác nhận"),
                  Tab(text: "Đang giao"),
                  Tab(text: "Lịch sử"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            buildOrderList(_pendingController, pendingOrders),
            buildOrderList(_deliveringController, deliveringOrders),
            buildOrderList(_deliveredController, deliveredOrders),
          ],
        ),
      ),
    );
  }

  Widget buildOrderList(
    PagingController<int, Map<String, dynamic>> controller,
    List<Map<String, dynamic>> orders,
  ) {
    return Column(
      children: [
        Expanded(
          child: PagedListView<int, Map<String, dynamic>>(
            pagingController: controller,
            padding: const EdgeInsets.all(16),

            builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
              itemBuilder: (context, order, index) {
                Widget? actionButton;
                Widget? refundButton;

                if (order["status"] == "Chờ xác nhận") {
                  actionButton = ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                              ),
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
                                    'Xác nhận hủy đơn',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Bạn có chắc chắn muốn hủy đơn hàng này không?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                        child: const Text('Không'),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          var order = pendingOrders[index];
                                          int orderId = order["id"];

                                          _handleOrder(orderId);
                                          final itemList = controller.itemList;
                                          if (itemList != null &&
                                              index >= 0 &&
                                              index < itemList.length) {
                                            setState(() {
                                              itemList.removeAt(index);
                                              pendingOrders.removeAt(index);
                                              controller.notifyListeners();
                                            });
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Hủy đơn'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Hủy đơn hàng",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else if (order["status"] == "Đã xác nhận") {
                  actionButton = ElevatedButton(
                    onPressed: () {
                      var order = deliveringOrders[index];
                      int orderId = order["id"];
                      _handleConfirmOrder(orderId);
                      final itemList = controller.itemList;
                      if (itemList != null &&
                          index >= 0 &&
                          index < itemList.length) {
                        setState(() {
                          itemList.removeAt(index);
                          deliveringOrders.removeAt(index);
                          controller.notifyListeners();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Đã nhận được hàng",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                  refundButton = OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Trả hàng/Hoàn tiền",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {}

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DetailOrderPage(orderId: order["id"]),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color.fromARGB(255, 247, 247, 247),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order["status"] ?? "Không xác định",
                                style: TextStyle(
                                  color:
                                      order["status"] == "Chờ xác nhận"
                                          ? Colors.red
                                          : order["status"] == "Đã xác nhận"
                                          ? Colors.green
                                          : order["status"] == "Đã hủy"
                                          ? Colors.red
                                          : order["status"] == "Hoàn tất"
                                          ? Colors.green
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        (order["image"] != null &&
                                                order["image"]
                                                    .toString()
                                                    .isNotEmpty)
                                            ? NetworkImage(order["image"])
                                            : AssetImage(
                                                  'assets/images/default.jpg',
                                                )
                                                as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order["name"] ?? "Sản phẩm không có tên",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      order["time"] ?? "Không có thời gian",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    (order["quantity"] - 1) > 0
                                        ? Text(
                                          "và ${order["quantity"] - 1} sản phẩm khác",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Tổng số tiền:",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "${order["totalPrice"]?.toString() ?? 'N/A'} ₫",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                refundButton != null
                                    ? MainAxisAlignment.spaceEvenly
                                    : MainAxisAlignment.end,

                            children: [
                              if (refundButton != null) refundButton,
                              const SizedBox(width: 10),
                              if (actionButton != null) actionButton!,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },

              firstPageProgressIndicatorBuilder:
                  (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      period: const Duration(seconds: 1),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              width: 150,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              width: 120,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              newPageProgressIndicatorBuilder:
                  (context) => const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 58),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Đang tải thêm ...",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              noItemsFoundIndicatorBuilder:
                  (context) => const Center(
                    child: Text(
                      "Không có đơn hàng nào!",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
