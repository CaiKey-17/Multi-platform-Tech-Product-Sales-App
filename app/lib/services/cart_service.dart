import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/cart_repository.dart';
import '../providers/cart_provider.dart';

class CartService {
  final CartRepository cartRepository;

  CartService({required this.cartRepository});

  Future<bool> addToCart({
    required int productID,
    required int colorId,
    required int id,
    required String? token,
    required dynamic context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userID = prefs.getInt('userId') ?? -1;
    String? tempID = prefs.getString('tempId') ?? "";
    String? authToken;

    if (token != null && token.isNotEmpty && token.split('.').length == 3) {
      authToken = token;
      userID = null;
    } else {
      authToken = null;
    }

    try {
      var response = await cartRepository.addToCart(
        token: authToken,
        productId: productID,
        colorId: colorId,
        quantity: 1,
        id: userID,
      );

      int statusCode = response["statusCode"] ?? 500;

      if (statusCode == 400) {
        Fluttertoast.showToast(
          msg: response["error"] ?? "Lỗi không xác định!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        if (response.containsKey("id")) {
          userID = response["id"];
          await prefs.setInt('userId', userID!);
        }

        if (response.containsKey("temp_id")) {
          tempID = response["temp_id"];
          final currentTempId = prefs.getString('tempId');

          if (currentTempId == null || !currentTempId.startsWith('T')) {
            await prefs.setString('tempId', tempID!);
          }
        }

        Fluttertoast.showToast(
          msg: response["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.fetchCartFromApi(userID);

        return true;
      }
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      Fluttertoast.showToast(
        msg: "Lỗi hệ thống! Vui lòng thử lại.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return false;
  }

  Future<bool> addMoreToCart({
    required int productID,
    required int colorId,
    required int id,
    required String? token,
    required dynamic context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userID = prefs.getInt('userId') ?? -1;
    String? authToken;

    if (token != null && token.isNotEmpty && token.split('.').length == 3) {
      authToken = token;
      userID = null;
    } else {
      authToken = null;
    }

    try {
      var response = await cartRepository.addToCart(
        token: authToken,
        productId: productID,
        colorId: colorId,
        quantity: 1,
        id: userID,
      );

      int statusCode = response["statusCode"] ?? 500;

      if (statusCode == 400) {
        Fluttertoast.showToast(
          msg: response["error"] ?? "Lỗi không xác định!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        if (response.containsKey("id")) {
          userID = response["id"];
          await prefs.setInt('userId', userID!);
        }
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.fetchCartFromApi(userID);

        return true;
      }
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      Fluttertoast.showToast(
        msg: "Lỗi hệ thống! Vui lòng thử lại.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return false;
  }

  Future<bool> minusMoreToCart({
    required int productId,
    required int orderId,
    required int id,
    required int userID,
    required int colorId,
    required dynamic context,
  }) async {
    try {
      print(productId);
      print(orderId);
      print(colorId);
      var response = await cartRepository.minusToCart(
        productId: productId,
        orderId: orderId,
        colorId: colorId,
      );

      int statusCode = response["statusCode"] ?? 500;

      if (statusCode == 400) {
        Fluttertoast.showToast(
          msg: response["error"] ?? "Lỗi không xác định!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.fetchCartFromApi(userID);

      return true;
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      Fluttertoast.showToast(
        msg: "Lỗi hệ thống! Vui lòng thử lại.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return false;
  }

  Future<bool> deleteToCart({
    required int orderDetailId,
    required dynamic context,
  }) async {
    try {
      var response = await cartRepository.deleteToCart(
        orderDetailId: orderDetailId,
      );

      int statusCode = response["statusCode"] ?? 500;

      if (statusCode == 400) {
        Fluttertoast.showToast(
          msg: response["error"] ?? "Lỗi không xác định!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        return true;
      }
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      Fluttertoast.showToast(
        msg: "Lỗi hệ thống! Vui lòng thử lại.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return false;
  }
}
