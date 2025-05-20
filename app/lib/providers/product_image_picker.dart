import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductImagePicker extends StatefulWidget {
  final String? imageUrl; 
  final ValueChanged<String?>? onImageChanged; 

  const ProductImagePicker({super.key, this.imageUrl, this.onImageChanged});

  @override
  _ProductImagePickerState createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  File? _selectedImage; 
  String? _imageUrl; 
  bool _isUploading = false; 
  String token = ""; 

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl; 
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await uploadImageToCloudinary();
    }
  }

  Future<void> uploadImageToCloudinary() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dwskd7iqr/upload";
      String uploadPreset = "flutter";

      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = jsonResponse['secure_url'];
        });

        widget.onImageChanged?.call(_imageUrl);

        print("✅ Upload thành công: $_imageUrl");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tải ảnh lên thành công")),
        );
      } else {
        print("❌ Lỗi khi upload: ${jsonResponse['error']['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải ảnh: ${jsonResponse['error']['message']}")),
        );
      }
    } catch (e) {
      print("❌ Lỗi upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải ảnh: $e")),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: token.isNotEmpty ? _pickImage : null,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          image: _imageUrl?.isNotEmpty == true
              ? DecorationImage(
                  image: NetworkImage(_imageUrl!),
                  fit: BoxFit.contain,
                )
              : widget.imageUrl?.isNotEmpty == true
                  ? DecorationImage(
                      image: NetworkImage(widget.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
        ),
        child: _imageUrl?.isNotEmpty == true || widget.imageUrl?.isNotEmpty == true
            ? null
            : _isUploading
                ? Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Center(child: Text("Chọn hình ảnh")),
      ),
    );
  }
}