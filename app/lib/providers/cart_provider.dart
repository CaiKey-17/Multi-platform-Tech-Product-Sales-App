import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final ApiService apiService;

  final Map<int, int> _cartItems = {};

  CartProvider({required this.apiService});

  int get cartItemCount =>
      _cartItems.values.fold(0, (sum, quantity) => sum + quantity);

  Map<int, int> get cartItems => _cartItems;

  void addItem(int id) {
    _cartItems[id] = (_cartItems[id] ?? 0) + 1;
    notifyListeners();
  }

  void minusItem(int id) {
    _cartItems[id] = (_cartItems[id] ?? 0) - 1;
    notifyListeners();
  }

  void removeItem(int id) {
    _cartItems.remove(id);
    notifyListeners();
  }

  void updateItem(int id, int quantity) {
    if (quantity > 0) {
      _cartItems[id] = quantity;
    } else {
      _cartItems.remove(id);
    }
    notifyListeners();
  }

  void removeItemCompletely(int id) {
    if (_cartItems.containsKey(id)) {
      _cartItems.remove(id);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> fetchCartFromApi(int? userId) async {
    try {
      final raw = await apiService.getRawQuantityInCart(userId);
      final mapped = raw.map(
        (key, value) => MapEntry(int.parse(key), value as int),
      );
      _cartItems
        ..clear()
        ..addAll(mapped);

      printCartItems();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi khi load giỏ hàng: $e");
    }
  }

  void printCartItems() {
    print('--- Cart Items ---');
    _cartItems.forEach((key, value) {
      print('Product ID: $key, Quantity: $value');
    });
  }
}
