import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app/globals/ip.dart';
import 'package:app/ui/product/main_category.dart';

class ImageUploader {
  final BuildContext context;
  final Function(String result) onResult;

  ImageUploader({required this.context, required this.onResult});

  Future<void> pickImageAndUpload() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          ),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.baseUrlDetect),
      );

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: pickedFile.name,
        );
        request.files.add(multipartFile);
      } else {
        // Flutter Mobile
        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          pickedFile.path,
        );
        request.files.add(multipartFile);
      }

      var res = await request.send();
      var response = await http.Response.fromStream(res);
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> objects = jsonResponse["objects"];

        Map<String, String> translationMap = {
          "laptop": "Laptop",
          "cell phone": "Điện thoại",
          "keyboard": "Bàn phím",
          "mouse": "Chuột",
          "tv": "Tivi",
          "monitor": "Màn hình",
          "computer": "PC - Máy tính",
        };

        String filteredResult = objects
            .where((obj) => obj["confidence"] > 0.7)
            .map((obj) => translationMap[obj["label"]] ?? obj["label"])
            .join(", ");

        if (filteredResult.isNotEmpty) {
          onResult(filteredResult);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CategoryPage(selectedCategory: filteredResult),
            ),
          );
        } else {
          showToast("Không có thiết bị nào nhận diện được !");
        }
      } else {
        showToast("Lỗi nhận diện!");
      }
    } catch (e) {
      Navigator.of(context).pop();
      showToast("Đã xảy ra lỗi kết nối!");
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
