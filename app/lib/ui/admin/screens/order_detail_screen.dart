import 'package:app/globals/ip.dart';
import 'package:app/luan/models/order_info.dart';
import 'package:app/luan/models/bill_info.dart';
import 'package:app/luan/models/product_variant_info.dart';
import 'package:app/models/cart_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderInfo order;
  final List<BillInfo> bills;
  final ProductVariant? variant;

  const OrderDetailsScreen({
    required this.order,
    required this.bills,
    this.variant,
    super.key,
  });

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late ApiAdminService apiService;
  late ApiService apiCartService;
  final Dio dio = Dio();
  String? productImage; // Lưu image từ Product
  List<CartInfo> cartItems = [];
  bool isLoadingCartItems = true;
  String? currentStatus; // Biến để theo dõi trạng thái hiện tại
  final List<String> orderStatuses = ['Chấp nhận', 'Không chấp nhận'];

  @override
  void initState() {
    super.initState();
    apiService = ApiAdminService(dio);
    apiCartService = ApiService(dio);
    currentStatus = widget.order.process; // Khởi tạo trạng thái từ order

    // In thông tin ProductVariant
    if (widget.variant != null) {
      debugPrint('ProductVariant:');
      debugPrint('  Name: ${widget.variant!.nameVariant}');
      debugPrint('  fkVariantProduct: ${widget.variant!.fkVariantProduct}');
    } else {
      debugPrint('ProductVariant is null');
    }

    // Lấy image từ Product qua API
    _fetchProductImage();
    // Lấy danh sách sản phẩm qua API
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      isLoadingCartItems = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1));
      List<CartInfo> response = await apiCartService.getItemInCartDetail(
        orderId: widget.order.id!,
      );
      setState(() {
        cartItems = response;
        isLoadingCartItems = false;
      });
    } catch (error, stackTrace) {
      debugPrint("Lỗi khi gọi API getItemInCartDetail: $error");
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        isLoadingCartItems = false;
      });
    }
  }

  Future<void> _fetchProductImage() async {
    if (widget.variant == null || widget.variant!.fkVariantProduct == null) {
      debugPrint(
        'Không thể lấy Product: variant hoặc fkVariantProduct là null',
      );
      return;
    }

    try {
      debugPrint(
        'Gọi API getProductById với ID: ${widget.variant!.fkVariantProduct}',
      );
      final product = await apiService.getProductById(
        widget.variant!.fkVariantProduct!,
      );
      setState(() {
        productImage = product.mainImage;
      });
      debugPrint('Product:');
      debugPrint('  Image: ${product.mainImage}');
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi lấy Product: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy thông tin sản phẩm: $e')),
      );
    }
  }

  String formatCurrency(double? amount) {
    try {
      if (amount == null) return 'N/A';
      return NumberFormat("#,###", "vi_VN").format(amount) + " VNĐ";
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi định dạng tiền tệ: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'N/A';
    }
  }

  String formatDate(String? date) {
    try {
      if (date == null) return 'N/A';
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi định dạng ngày: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'N/A';
    }
  }

  String _translateStatus(String? backendStatus) {
    try {
      switch (backendStatus?.toLowerCase()) {
        case 'dangdat':
          return 'Đang đặt';
        case 'danggiao':
          return 'Đang giao';
        case 'dahuy':
          return 'Đã hủy';
        case 'hoantat':
          return 'Hoàn tất';
        default:
          debugPrint('Trạng thái backend không xác định: $backendStatus');
          return 'Đang đặt';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi dịch trạng thái: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'Đang đặt';
    }
  }

  String _toBackendStatus(String uiStatus) {
    try {
      switch (uiStatus) {
        case 'Chấp nhận':
          return 'danggiao';
        case 'Không chấp nhận':
          return 'dahuy';
        default:
          debugPrint('Trạng thái giao diện không xác định: $uiStatus');
          return 'dangdat';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi chuyển trạng thái sang backend: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'dangdat';
    }
  }

  String _getPaymentStatus() {
    try {
      if (widget.bills.isEmpty) {
        debugPrint('Không tìm thấy bill cho đơn hàng ID: ${widget.order.id}');
        return 'Chưa thanh toán';
      }
      if (widget.bills.any(
        (bill) => bill.statusOrder?.toLowerCase() == 'dathanhtoan',
      )) {
        return 'Đã thanh toán';
      }
      return 'Chưa thanh toán';
    } catch (e, stackTrace) {
      debugPrint(
        'Lỗi khi lấy trạng thái thanh toán cho đơn hàng ${widget.order.id}: $e',
      );
      debugPrint('StackTrace: $stackTrace');
      return 'Chưa thanh toán';
    }
  }

  String _getPaymentMethod() {
    try {
      if (widget.bills.isEmpty || widget.bills.first.methodPayment == null) {
        debugPrint(
          'Không có phương thức thanh toán cho đơn hàng ID: ${widget.order.id}',
        );
        return 'N/A';
      }
      final method = widget.bills.first.methodPayment!.toLowerCase();
      if (method == 'tienmat') {
        return 'Tiền mặt';
      }
      return widget.bills.first.methodPayment!;
    } catch (e, stackTrace) {
      debugPrint(
        'Lỗi khi lấy phương thức thanh toán cho đơn hàng ${widget.order.id}: $e',
      );
      debugPrint('StackTrace: $stackTrace');
      return 'N/A';
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    if (widget.order.id == null) {
      debugPrint('Lỗi: order.id là null khi cập nhật trạng thái');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không xác định được ID đơn hàng')),
      );
      return;
    }

    try {
      debugPrint(
        'Cập nhật trạng thái cho đơn hàng ID: ${widget.order.id}, Trạng thái mới: $newStatus',
      );
      final backendStatus = _toBackendStatus(newStatus);
      debugPrint(
        'Gửi yêu cầu cập nhật trạng thái tới backend: orderId=${widget.order.id}, process=$backendStatus',
      );

      // Gọi API để cập nhật trạng thái
      if (newStatus == 'Chấp nhận') {
        await apiCartService.acceptToCart(widget.order.id!);
        debugPrint('Chấp nhận đơn hàng ID: ${widget.order.id} thành công');
      } else if (newStatus == 'Không chấp nhận') {
        await apiCartService.cancelToCart(widget.order.id!);
        debugPrint('Hủy đơn hàng ID: ${widget.order.id} thành công');
      } else {
        throw Exception('Trạng thái không hợp lệ: $newStatus');
      }

      // Cập nhật trạng thái cục bộ mà không gọi lại dữ liệu khác
      setState(() {
        currentStatus = backendStatus;
        widget.order.process = backendStatus; // Cập nhật trạng thái trong order
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật trạng thái đơn hàng thành công'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Lỗi khi cập nhật trạng thái đơn hàng ID: ${widget.order.id}: $e',
      );
      debugPrint('StackTrace: $stackTrace');
      String errorMessage = 'Lỗi khi cập nhật trạng thái: $e';
      if (e is DioException) {
        errorMessage =
            'Lỗi khi cập nhật trạng thái: ${e.response?.statusCode} - ${e.message}';
        debugPrint(
          'DioException details: StatusCode=${e.response?.statusCode}, ResponseData=${e.response?.data}',
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => {Navigator.pop(context)},
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin sản phẩm
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thông tin sản phẩm",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      isLoadingCartItems
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                          : cartItems.isEmpty
                          ? const Center(
                            child: Text(
                              "Không có sản phẩm",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                                  height: 80,
                                                )
                                                : Image.network(
                                                  item.image!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 80,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Image.asset(
                                                      'assets/images/default.jpg',
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: 80,
                                                    );
                                                  },
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.nameVariant ?? 'N/A',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.blue,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            (item.colorName?.trim().isEmpty ??
                                                    true)
                                                ? 'Mặc định'
                                                : item.colorName!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Số lượng: ${item.quantity ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "Giá: ${formatCurrency(item.price)}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      const SizedBox(height: 10),
                      Text(
                        "Phí ship: ${formatCurrency(widget.order.ship)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              // Thông tin đơn hàng
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thông tin đơn hàng",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        "Mã đơn",
                        'ORD${widget.order.id.toString().padLeft(3, '0')}',
                      ),
                      _buildInfoRow(
                        "Giá",
                        formatCurrency(widget.order.priceTotal),
                      ),
                      _buildInfoRow(
                        "Số lượng",
                        widget.order.quantityTotal?.toString() ?? 'N/A',
                      ),
                      _buildInfoRow(
                        "Phí ship",
                        formatCurrency(widget.order.ship),
                      ),
                      _buildInfoRow("Thuế", formatCurrency(widget.order.tax)),
                      _buildInfoRow(
                        "Tổng tiền",
                        formatCurrency(widget.order.total),
                        isBold: true,
                        valueColor: Colors.red,
                      ),
                      _buildInfoRow(
                        "Địa chỉ",
                        widget.order.address ?? 'N/A',
                        isAddress: true,
                      ),
                      _buildInfoRow(
                        "Phương thức thanh toán",
                        _getPaymentMethod(),
                      ),
                      _buildInfoRow(
                        "Chiết khấu",
                        formatCurrency(widget.order.couponTotal),
                      ),
                      _buildInfoRow(
                        "Điểm",
                        formatCurrency(widget.order.pointTotal),
                      ),
                      _buildInfoRow(
                        "Thời gian",
                        formatDate(widget.order.createdAt),
                      ),
                      _buildInfoRow(
                        "Trạng thái thanh toán",
                        _getPaymentStatus(),
                        valueColor:
                            _getPaymentStatus() == 'Đã thanh toán'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              // Cập nhật trạng thái
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cập nhật trạng thái",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Trạng thái",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _translateStatus(widget.order.process),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        widget.order.process?.toLowerCase() ==
                                                'danggiao'
                                            ? Colors.green
                                            : widget.order.process
                                                    ?.toLowerCase() ==
                                                'dahuy'
                                            ? Colors.red
                                            : widget.order.process
                                                    ?.toLowerCase() ==
                                                'hoantat'
                                            ? Colors.blue
                                            : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Hành động",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                _buildActionWidget(),
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
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    bool isAddress = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              softWrap: isAddress,
              overflow:
                  isAddress ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionWidget() {
    try {
      final backendStatus = currentStatus?.toLowerCase();
      if (backendStatus == 'dangdat') {
        return DropdownButton<String>(
          hint: const Text('Chọn hành động'),
          onChanged: (newValue) {
            try {
              if (newValue != null) {
                debugPrint(
                  'Thay đổi trạng thái cho đơn hàng ID: ${widget.order.id} thành: $newValue',
                );
                _updateOrderStatus(newValue);
              } else {
                debugPrint(
                  'Không có giá trị trạng thái mới cho đơn hàng ID: ${widget.order.id}',
                );
              }
            } catch (e, stackTrace) {
              debugPrint(
                'Lỗi khi thay đổi trạng thái dropdown cho đơn hàng ID: ${widget.order.id}: $e',
              );
              debugPrint('StackTrace: $stackTrace');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi thay đổi trạng thái: $e')),
              );
            }
          },
          items:
              orderStatuses.map<DropdownMenuItem<String>>((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      color: status == 'Chấp nhận' ? Colors.green : Colors.red,
                    ),
                  ),
                );
              }).toList(),
        );
      } else if (backendStatus == 'danggiao') {
        return const Text(
          'Đã chấp nhận',
          style: TextStyle(fontSize: 14, color: Colors.green),
          textAlign: TextAlign.center,
        );
      } else if (backendStatus == 'dahuy') {
        return const Text(
          'Không chấp nhận',
          style: TextStyle(fontSize: 14, color: Colors.red),
          textAlign: TextAlign.center,
        );
      } else if (backendStatus == 'hoantat') {
        return const Text(
          'Hoàn tất',
          style: TextStyle(fontSize: 14, color: Colors.blue),
          textAlign: TextAlign.center,
        );
      }
      return const SizedBox.shrink();
    } catch (e, stackTrace) {
      debugPrint(
        'Lỗi khi xây dựng widget hành động cho đơn hàng ID: ${widget.order.id}: $e',
      );
      debugPrint('StackTrace: $stackTrace');
      return const SizedBox.shrink();
    }
  }
}
