import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BrandImagePicker extends StatefulWidget {
  final String? imageUrl;
  final ValueChanged<String?>? onImageChanged;

  const BrandImagePicker({super.key, this.imageUrl, this.onImageChanged});

  @override
  _BrandImagePickerState createState() => _BrandImagePickerState();
}

class _BrandImagePickerState extends State<BrandImagePicker> {
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
      } else {
        print("❌ Lỗi khi upload: ${jsonResponse['error']['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi tải ảnh: ${jsonResponse['error']['message']}"),
          ),
        );
      }
    } catch (e) {
      print("❌ Lỗi upload: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải ảnh: $e")));
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: token.isNotEmpty ? _pickImage : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image:
                _imageUrl?.isNotEmpty == true
                    ? NetworkImage(_imageUrl!)
                    : widget.imageUrl?.isNotEmpty == true
                    ? NetworkImage(widget.imageUrl!)
                    : AssetImage('assets/images/default.jpg') as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),

        child:
            (_imageUrl?.isNotEmpty != true &&
                    widget.imageUrl?.isNotEmpty != true)
                ? (_isUploading
                    ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : null)
                : null,
      ),
    );
  }
}
