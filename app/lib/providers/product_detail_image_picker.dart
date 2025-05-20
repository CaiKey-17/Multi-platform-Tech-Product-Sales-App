import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/luan/models/product_image_info.dart'; // Import ProductImage model
import 'package:dio/dio.dart';

/// A widget for selecting, uploading, and displaying multiple product images.
class ProductDetailImagePicker extends StatefulWidget {
  final List<String> imageUrls; // Initial list of image URLs
  final ValueChanged<List<String>>? onImagesChanged; // Callback when image URLs change
  final bool isEdit; // Whether the widget is in edit mode
  final int? productId; // Product ID for fetching images in edit mode

  const ProductDetailImagePicker({
    super.key,
    this.imageUrls = const [],
    this.onImagesChanged,
    required this.isEdit,
    this.productId,
  });

  @override
  State<ProductDetailImagePicker> createState() => _ProductDetailImagePickerState();
}

class _ProductDetailImagePickerState extends State<ProductDetailImagePicker> {
  List<String> _imageUrls = [];
  bool _isUploading = false;
  bool _isFetching = false;
  String _token = '';
  late final ApiAdminService _apiAdminService;

  @override
  void initState() {
    super.initState();
    _apiAdminService = ApiAdminService(Dio());
    _imageUrls = List.from(widget.imageUrls);
    _loadToken();
    if (widget.isEdit && widget.productId != null) {
      _fetchImageUrls();
    }
  }

  /// Loads the authentication token from SharedPreferences.
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _token = prefs.getString('token') ?? '';
    });
  }

  /// Fetches image URLs for the product from the API in edit mode.
  Future<void> _fetchImageUrls() async {
    if (widget.productId == null) return;
    setState(() {
      _isFetching = true;
    });
    try {
      final images = await _apiAdminService.getImagesByProduct(widget.productId!);
      if (!mounted) return;
      setState(() {
        _imageUrls = images
            .map((image) => image.image)
            .where((url) => url != null)
            .cast<String>()
            .toList();
        widget.onImagesChanged?.call(_imageUrls);
      });
      debugPrint('Fetched image URLs: $_imageUrls');
    } catch (e) {
      debugPrint('Error fetching image URLs: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách ảnh: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
      });
    }
  }

  /// Opens the image picker to select multiple images and uploads them.
  Future<void> _pickImages() async {
    if (_token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để chọn ảnh')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    final newImageUrls = <String>[];
    for (var file in pickedFiles) {
      final imageUrl = await _uploadImageToCloudinary(File(file.path));
      if (imageUrl != null) {
        newImageUrls.add(imageUrl);
      }
    }

    if (!mounted) return;
    setState(() {
      _imageUrls.addAll(newImageUrls);
      _isUploading = false;
    });

    debugPrint('Current image URLs: $_imageUrls');
    widget.onImagesChanged?.call(_imageUrls);

    if (newImageUrls.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải lên ${newImageUrls.length} ảnh thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có ảnh nào được tải lên')),
      );
    }
  }

  /// Uploads an image to Cloudinary and returns the secure URL.
  Future<String?> _uploadImageToCloudinary(File image) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dwskd7iqr/upload';
    const uploadPreset = 'flutter';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'] as String;
        debugPrint('Uploaded image: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('Upload error: ${jsonResponse['error']['message']}');
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: ${jsonResponse['error']['message']}')),
        );
        return null;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải ảnh: $e')),
      );
      return null;
    }
  }

  /// Removes an image from the list.
  void _removeImage(int index) {
    if (!mounted) return;
    setState(() {
      _imageUrls.removeAt(index);
      widget.onImagesChanged?.call(_imageUrls);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa ảnh')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh bổ sung',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isUploading || _isFetching
                ? const Center(child: CircularProgressIndicator())
                : _imageUrls.isEmpty
                    ? const Center(child: Text('Chọn nhiều hình ảnh bổ sung'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_imageUrls.length, (index) {
                            final imageUrl = _imageUrls[index];
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      color: Colors.red,
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}