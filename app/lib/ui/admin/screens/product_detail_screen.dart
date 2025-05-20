import 'package:app/globals/convert_money.dart';
import 'package:app/luan/models/product_color_info.dart';
import 'package:app/luan/models/product_image_info.dart';
import 'package:app/luan/models/product_info.dart';
import 'package:app/luan/models/product_variant_info.dart';
import 'package:app/providers/product_detail_image_picker.dart';
import 'package:app/providers/product_image_picker.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/ui/admin/product_details_admin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class ProductDetailScreen extends StatefulWidget {
  final bool isEdit;
  final ProductInfo? productInfo;
  final Function(Map<String, dynamic>)? onSave;

  ProductDetailScreen({required this.isEdit, this.productInfo, this.onSave});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late ApiAdminService apiAdminService;
  bool isLoading = false;
  String? errorMessage;

  List<String> productTypes = [];
  List<String> brands = [];
  String? selectedProductType;
  String? selectedBrand;

  List<ProductVariant> variants = [];
  List<List<ProductColor>> variantColors = [];
  List<List<String?>> colorImages = [];

  int selectedVersionIndex = -1;
  int selectedColorIndex = -1;

  final TextEditingController _newColorController = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController();
  final TextEditingController _newVersionController = TextEditingController();
  final TextEditingController _newVersionImportPriceController =
      TextEditingController();
  final TextEditingController _newVersionOriginalPriceController =
      TextEditingController();
  final TextEditingController _newVersionQuantityController =
      TextEditingController();
  final TextEditingController _newVersionDiscountPercentController =
      TextEditingController();
  final TextEditingController _newQuantityController = TextEditingController();

  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  List<Map<String, String>> specifications = [];
  bool showTitleInput = false;
  bool showKeyValueInput = false;
  bool hasColors = false;

  String? _imagePath;
  List<String> _additionalImages = [];
  String token = "";

  final TextEditingController _variantImportPriceController =
      TextEditingController();
  final TextEditingController _variantOriginalPriceController =
      TextEditingController();
  final TextEditingController _variantQuantityController =
      TextEditingController();
  final TextEditingController _variantDiscountPercentController =
      TextEditingController();
  final TextEditingController _variantPriceController = TextEditingController();

  final TextEditingController _colorNameController = TextEditingController();
  final TextEditingController _colorPriceController = TextEditingController();
  final TextEditingController _colorQuantityController =
      TextEditingController();

  bool _hasChanges = false;
  Map<String, dynamic> _initialValues = {};
  ProductInfo? _savedProduct;

  @override
  void initState() {
    super.initState();
    apiAdminService = ApiAdminService(Dio());

    if (widget.isEdit && widget.productInfo != null) {
      _nameController = TextEditingController(text: widget.productInfo!.name);
      _descriptionController = TextEditingController(
        text: widget.productInfo!.shortDescription,
      );
      selectedProductType = widget.productInfo!.fkCategory;
      selectedBrand = widget.productInfo!.fkBrand;
      _imagePath = widget.productInfo!.mainImage;
      hasColors = widget.productInfo!.hasColor;
      specifications = _parseDetailToSpecifications(widget.productInfo!.detail);
      _savedProduct = widget.productInfo;
      _fetchVariants();
      _fetchAdditionalImages();
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _imagePath = null;
      selectedVersionIndex = -1;
      selectedColorIndex = -1;
    }

    _updateInitialValues();

    _nameController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
    _newColorController.addListener(_checkForChanges);
    _newPriceController.addListener(_checkForChanges);
    _newVersionController.addListener(_checkForChanges);
    _newVersionImportPriceController.addListener(_checkForChanges);
    _newVersionOriginalPriceController.addListener(_checkForChanges);
    _newVersionQuantityController.addListener(_checkForChanges);
    _newVersionDiscountPercentController.addListener(_checkForChanges);
    _newQuantityController.addListener(_checkForChanges);
    _keyController.addListener(_checkForChanges);
    _valueController.addListener(_checkForChanges);
    _variantImportPriceController.addListener(_checkForChanges);
    _variantOriginalPriceController.addListener(_checkForChanges);
    _variantQuantityController.addListener(_checkForChanges);
    _variantDiscountPercentController.addListener(_checkForChanges);
    _colorNameController.addListener(_checkForChanges);
    _colorPriceController.addListener(_checkForChanges);
    _colorQuantityController.addListener(_checkForChanges);

    _fetchBrandsAndCategories();
    _loadUserData();
  }

  void _updateInitialValues() {
    _initialValues = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'productType': selectedProductType,
      'brand': selectedBrand,
      'imagePath': _imagePath,
      'additionalImages': List<String>.from(_additionalImages),
      'specifications': List<Map<String, String>>.from(
        specifications.map((spec) => Map<String, String>.from(spec)),
      ),
      'variants':
          variants
              .map(
                (v) => {
                  'id': v.id,
                  'nameVariant': v.nameVariant,
                  'importPrice': v.importPrice,
                  'originalPrice': v.originalPrice,
                  'quantity': v.quantity,
                  'discountPercent': v.discountPercent,
                  'fkVariantProduct': v.fkVariantProduct,
                },
              )
              .toList(),
      'variantColors':
          variantColors
              .map(
                (colors) =>
                    colors
                        .map(
                          (c) => {
                            'id': c.id,
                            'colorName': c.colorName,
                            'colorPrice': c.colorPrice,
                            'quantity': c.quantity,
                            'image': c.image,
                            'fkVariantProduct': c.fkVariantProduct,
                          },
                        )
                        .toList(),
              )
              .toList(),
      'colorImages':
          colorImages.map((images) => List<String?>.from(images)).toList(),
      'hasColors': hasColors,
    };
  }

  void _checkForChanges() {
    if (!mounted) return;
    bool hasChanges = false;

    if (_nameController.text != _initialValues['name']) hasChanges = true;
    if (_descriptionController.text != _initialValues['description'])
      hasChanges = true;
    if (selectedProductType != _initialValues['productType']) hasChanges = true;
    if (selectedBrand != _initialValues['brand']) hasChanges = true;
    if (_imagePath != _initialValues['imagePath']) hasChanges = true;
    if (_additionalImages.length !=
            (_initialValues['additionalImages'] as List).length ||
        _additionalImages.asMap().entries.any(
          (e) => e.value != (_initialValues['additionalImages'] as List)[e.key],
        )) {
      hasChanges = true;
    }

    if (specifications.length !=
            (_initialValues['specifications'] as List).length ||
        specifications.asMap().entries.any((entry) {
          int i = entry.key;
          Map<String, String> spec = entry.value;
          Map<String, String> initialSpec =
              (_initialValues['specifications'] as List)[i];
          return spec.keys.first != initialSpec.keys.first ||
              spec.values.first != initialSpec.values.first;
        })) {
      hasChanges = true;
    }

    if (variants.length != (_initialValues['variants'] as List).length ||
        variants.asMap().entries.any((entry) {
          int i = entry.key;
          ProductVariant v = entry.value;
          Map<String, dynamic> initialV =
              (_initialValues['variants'] as List)[i];
          return v.nameVariant != initialV['nameVariant'] ||
              v.importPrice != initialV['importPrice'] ||
              v.originalPrice != initialV['originalPrice'] ||
              v.quantity != initialV['quantity'] ||
              v.discountPercent != initialV['discountPercent'];
        })) {
      hasChanges = true;
    }

    if (variantColors.length !=
            (_initialValues['variantColors'] as List).length ||
        variantColors.asMap().entries.any((entry) {
          int i = entry.key;
          List<ProductColor> colors = entry.value;
          List<Map<String, dynamic>> initialColors =
              (_initialValues['variantColors'] as List)[i];
          if (colors.length != initialColors.length) return true;
          return colors.asMap().entries.any((colorEntry) {
            int j = colorEntry.key;
            ProductColor c = colorEntry.value;
            Map<String, dynamic> initialC = initialColors[j];
            return c.colorName != initialC['colorName'] ||
                c.colorPrice != initialC['colorPrice'] ||
                c.quantity != initialC['quantity'] ||
                c.image != initialC['image'];
          });
        })) {
      hasChanges = true;
    }

    if (colorImages.length != (_initialValues['colorImages'] as List).length ||
        colorImages.asMap().entries.any((entry) {
          int i = entry.key;
          List<String?> images = entry.value;
          List<String?> initialImages =
              (_initialValues['colorImages'] as List)[i];
          if (images.length != initialImages.length) return true;
          return images.asMap().entries.any(
            (imgEntry) => imgEntry.value != initialImages[imgEntry.key],
          );
        })) {
      hasChanges = true;
    }

    if (hasColors != _initialValues['hasColors']) hasChanges = true;

    if (_newColorController.text.isNotEmpty ||
        _newPriceController.text.isNotEmpty ||
        _newVersionController.text.isNotEmpty ||
        _newVersionImportPriceController.text.isNotEmpty ||
        _newVersionOriginalPriceController.text.isNotEmpty ||
        _newVersionQuantityController.text.isNotEmpty ||
        _newVersionDiscountPercentController.text.isNotEmpty ||
        _newQuantityController.text.isNotEmpty ||
        _keyController.text.isNotEmpty ||
        _valueController.text.isNotEmpty) {
      hasChanges = true;
    }

    if (mounted) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _descriptionController.removeListener(_checkForChanges);
    _newColorController.removeListener(_checkForChanges);
    _newPriceController.removeListener(_checkForChanges);
    _newVersionController.removeListener(_checkForChanges);
    _newVersionImportPriceController.removeListener(_checkForChanges);
    _newVersionOriginalPriceController.removeListener(_checkForChanges);
    _newVersionQuantityController.removeListener(_checkForChanges);
    _newVersionDiscountPercentController.removeListener(_checkForChanges);
    _newQuantityController.removeListener(_checkForChanges);
    _keyController.removeListener(_checkForChanges);
    _valueController.removeListener(_checkForChanges);
    _variantImportPriceController.removeListener(_checkForChanges);
    _variantOriginalPriceController.removeListener(_checkForChanges);
    _variantQuantityController.removeListener(_checkForChanges);
    _variantDiscountPercentController.removeListener(_checkForChanges);
    _colorNameController.removeListener(_checkForChanges);
    _colorPriceController.removeListener(_checkForChanges);
    _colorQuantityController.removeListener(_checkForChanges);

    _nameController.dispose();
    _descriptionController.dispose();
    _newColorController.dispose();
    _newPriceController.dispose();
    _newVersionController.dispose();
    _newVersionImportPriceController.dispose();
    _newVersionOriginalPriceController.dispose();
    _newVersionQuantityController.dispose();
    _newVersionDiscountPercentController.dispose();
    _newQuantityController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    _variantImportPriceController.dispose();
    _variantOriginalPriceController.dispose();
    _variantQuantityController.dispose();
    _variantDiscountPercentController.dispose();
    _variantPriceController.dispose();
    _colorNameController.dispose();
    _colorPriceController.dispose();
    _colorQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      token = prefs.getString('token') ?? "";
      _checkForChanges();
    });
  }

  List<Map<String, String>> _parseDetailToSpecifications(String? detail) {
    List<Map<String, String>> specs = [];
    if (detail == null || detail.isEmpty) {
      developer.log("Detail is null or empty, returning empty specifications");
      return specs;
    }

    List<String> pairs = detail.split(';').map((e) => e.trim()).toList();
    for (String pair in pairs) {
      if (pair.isEmpty) continue;
      pair = pair.replaceAll(RegExp(r',\s*$'), '');
      List<String> keyValue = pair.split(':').map((e) => e.trim()).toList();
      if (keyValue.length != 2 || keyValue[0].isEmpty || keyValue[1].isEmpty) {
        developer.log("Invalid key-value pair skipped: $pair");
        continue;
      }
      String key = keyValue[0];
      String value = keyValue[1];
      if (key.toLowerCase() == 'title') {
        specs.add({'Title': value});
      } else {
        specs.add({key: value});
      }
    }
    return specs;
  }

  Future<void> _fetchBrandsAndCategories() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final brandNamesFuture = apiAdminService.getAllBrandNames();
      final categoryNamesFuture = apiAdminService.getAllCategoryNames();
      final results = await Future.wait([
        brandNamesFuture,
        categoryNamesFuture,
      ]);
      if (!mounted) return;
      setState(() {
        brands = results[0] as List<String>;
        productTypes = results[1] as List<String>;
        if (brands.isNotEmpty &&
            (selectedBrand == null || !brands.contains(selectedBrand))) {
          selectedBrand = brands.first;
        } else if (brands.isEmpty) {
          selectedBrand = null;
          errorMessage =
              "Không có danh sách hãng. Vui lòng kiểm tra API /admin/brand/names.";
        }
        if (productTypes.isNotEmpty &&
            (selectedProductType == null ||
                !productTypes.contains(selectedProductType))) {
          selectedProductType = productTypes.first;
        } else if (productTypes.isEmpty) {
          selectedProductType = null;
          errorMessage =
              errorMessage != null
                  ? "$errorMessage\nKhông có danh sách danh mục."
                  : "Không có danh sách danh mục. Vui lòng kiểm tra API /admin/category/names.";
        }
        _checkForChanges();
      });
    } catch (e) {
      developer.log("Error fetching brands or categories: $e");
      if (!mounted) return;
      setState(() {
        errorMessage = "Không thể tải danh sách hãng hoặc danh mục: $e";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchVariants() async {
    if (!widget.isEdit ||
        widget.productInfo == null ||
        widget.productInfo!.id == null) {
      if (!mounted) return;
      setState(() {
        errorMessage =
            "Thông tin sản phẩm không hợp lệ. Vui lòng kiểm tra ID sản phẩm.";
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final productId = widget.productInfo!.id!;
      final variantsData = await apiAdminService.getVariantsByProductId(
        productId,
      );
      if (!mounted) return;
      setState(() {
        variants = variantsData;
        variantColors = List.generate(variants.length, (_) => []);
        colorImages = List.generate(variants.length, (_) => []);
        selectedVersionIndex = variants.isNotEmpty ? 0 : -1;
        selectedColorIndex = -1;
        if (selectedVersionIndex >= 0 && variants.isNotEmpty) {
          _updateVariantControllers();
        }
        _updateInitialValues();
        _checkForChanges();
      });
      if (widget.productInfo!.hasColor && variants.isNotEmpty) {
        await _fetchColorsForVariants();
      }
    } catch (e) {
      developer.log("Error fetching variants: $e");
      if (!mounted) return;
      setState(() {
        errorMessage = "Không thể tải danh sách biến thể: $e";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAdditionalImages() async {
    if (!widget.isEdit ||
        widget.productInfo == null ||
        widget.productInfo!.id == null) {
      return;
    }
    try {
      final productId = widget.productInfo!.id!;
      final images = await apiAdminService.getImagesByProduct(productId);
      if (!mounted) return;
      setState(() {
        _additionalImages =
            images
                .map((image) => image.image)
                .where((url) => url != null)
                .cast<String>()
                .toList();
        _updateInitialValues();
        _checkForChanges();
      });
    } catch (e) {
      developer.log("Error fetching additional images: $e");
      if (!mounted) return;
      setState(() {
        errorMessage = "Không thể tải danh sách ảnh bổ sung: $e";
      });
    }
  }

  Future<void> _fetchColorsForVariants() async {
    for (int i = 0; i < variants.length; i++) {
      try {
        final variantId = variants[i].id;
        final colors = await apiAdminService.getColorsByVariantId(variantId);
        if (!mounted) return;
        setState(() {
          variantColors[i] = colors;
          colorImages[i] = colors.map((color) => color.image).toList();
          if (i == selectedVersionIndex && colors.isNotEmpty) {
            selectedColorIndex = 0;
            _updateColorControllers();
          }
          _updateInitialValues();
          _checkForChanges();
        });
      } catch (e) {
        developer.log(
          "Error fetching colors for variant ${variants[i].id}: $e",
        );
        if (!mounted) return;
        setState(() {
          errorMessage =
              "Không thể tải danh sách màu cho biến thể ${variants[i].nameVariant}: $e";
        });
      }
    }
  }

  void _updateVariantControllers() {
    if (!mounted) return;
    if (selectedVersionIndex >= 0 &&
        selectedVersionIndex < variants.length &&
        variants.isNotEmpty) {
      final variant = variants[selectedVersionIndex];
      _variantImportPriceController.text =
          variant.importPrice?.toStringAsFixed(0) ?? '';
      _variantOriginalPriceController.text =
          variant.originalPrice?.toStringAsFixed(0) ?? '';
      _variantQuantityController.text = variant.quantity?.toString() ?? '';
      _variantDiscountPercentController.text =
          variant.discountPercent?.toString() ?? '';
      final calculatedPrice = _calculateFinalPrice(
        variant.originalPrice,
        variant.discountPercent,
      );
      _variantPriceController.text = calculatedPrice.toStringAsFixed(0);
      _checkForChanges();
    }
  }

  void _updateColorControllers() {
    if (!mounted) return;
    if (selectedVersionIndex >= 0 &&
        selectedColorIndex >= 0 &&
        selectedVersionIndex < variants.length &&
        selectedVersionIndex < variantColors.length &&
        selectedColorIndex < variantColors[selectedVersionIndex].length) {
      final color = variantColors[selectedVersionIndex][selectedColorIndex];
      _colorNameController.text = color.colorName;
      _colorPriceController.text = color.colorPrice.toStringAsFixed(0);
      _colorQuantityController.text = color.quantity?.toString() ?? '';
      _checkForChanges();
    }
  }

  double _calculateFinalPrice(double? originalPrice, int? discountPercent) {
    final price = originalPrice ?? 0;
    final discount = discountPercent ?? 0;
    return price * (1 - discount / 100);
  }

  void _updateVariant() {
    if (!mounted) return;
    if (selectedVersionIndex >= 0 && selectedVersionIndex < variants.length) {
      final originalPrice =
          double.tryParse(_variantOriginalPriceController.text) ??
          variants[selectedVersionIndex].originalPrice ??
          0;
      int discountPercent =
          int.tryParse(_variantDiscountPercentController.text) ??
          variants[selectedVersionIndex].discountPercent ??
          0;

      if (discountPercent > 50) {
        discountPercent = 50;
        _variantDiscountPercentController.text = '50';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phần trăm giảm giá tối đa là 50%.")),
        );
      }

      final calculatedPrice = _calculateFinalPrice(
        originalPrice,
        discountPercent,
      );

      setState(() {
        variants[selectedVersionIndex] = ProductVariant(
          id: variants[selectedVersionIndex].id,
          nameVariant: variants[selectedVersionIndex].nameVariant,
          importPrice:
              double.tryParse(_variantImportPriceController.text) ??
              variants[selectedVersionIndex].importPrice ??
              0,
          originalPrice: originalPrice,
          quantity:
              int.tryParse(_variantQuantityController.text) ??
              variants[selectedVersionIndex].quantity ??
              0,
          discountPercent: discountPercent,
          price: calculatedPrice,
          fkVariantProduct: variants[selectedVersionIndex].fkVariantProduct,
        );
        _variantPriceController.text = calculatedPrice.toStringAsFixed(0);
        _checkForChanges();
      });
    }
  }

  void _updateColor() {
    if (!mounted) return;
    if (selectedVersionIndex >= 0 &&
        selectedColorIndex >= 0 &&
        selectedVersionIndex < variantColors.length &&
        selectedColorIndex < variantColors[selectedVersionIndex].length) {
      setState(() {
        variantColors[selectedVersionIndex][selectedColorIndex] = ProductColor(
          id: variantColors[selectedVersionIndex][selectedColorIndex].id,
          colorName:
              _colorNameController.text.isNotEmpty
                  ? _colorNameController.text
                  : variantColors[selectedVersionIndex][selectedColorIndex]
                      .colorName,
          colorPrice:
              double.tryParse(_colorPriceController.text) ??
              variantColors[selectedVersionIndex][selectedColorIndex]
                  .colorPrice,
          quantity:
              int.tryParse(_colorQuantityController.text) ??
              variantColors[selectedVersionIndex][selectedColorIndex].quantity,
          image: variantColors[selectedVersionIndex][selectedColorIndex].image,
          fkVariantProduct:
              variantColors[selectedVersionIndex][selectedColorIndex]
                  .fkVariantProduct,
        );
        _checkForChanges();
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(child: CircularProgressIndicator()),
          ),
    );

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (_nameController.text.isEmpty ||
          selectedProductType == null ||
          selectedBrand == null) {
        throw Exception("Tên sản phẩm, danh mục và hãng không được để trống.");
      }
      if (variants.isEmpty) {
        Fluttertoast.showToast(
          msg: "Sản phẩm phải có ít nhất một biến thể.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        throw Exception("Sản phẩm phải có ít nhất một biến thể.");
      }

      bool determinedHasColors = variantColors.any(
        (colors) => colors.isNotEmpty,
      );
      hasColors = determinedHasColors;

      ProductInfo productInfo = ProductInfo(
        id:
            _savedProduct?.id ??
            (widget.isEdit ? widget.productInfo!.id : null),
        name: _nameController.text,
        fkCategory: selectedProductType!,
        fkBrand: selectedBrand!,
        mainImage: _imagePath,
        shortDescription: _descriptionController.text,
        detail: specifications
            .map((spec) => "${spec.keys.first}: ${spec.values.first}")
            .join('; '),
        hasColor: hasColors,
      );

      developer.log("Saving product: ${productInfo.toJson()}");

      if (_savedProduct == null && !widget.isEdit) {
        _savedProduct = await apiAdminService.createProduct(productInfo);
        developer.log("Created new product with ID: ${_savedProduct!.id}");
      } else {
        _savedProduct = await apiAdminService.updateProduct(
          productInfo.id!,
          productInfo,
        );
        developer.log("Updated product with ID: ${_savedProduct!.id}");
      }

      if (_additionalImages.isNotEmpty || widget.isEdit) {
        if (widget.isEdit) {
          List<String> initialImages = List<String>.from(
            _initialValues['additionalImages'],
          );
          List<String> currentImages = _additionalImages;

          List<String> imagesToAdd =
              currentImages
                  .where((img) => !initialImages.contains(img))
                  .toList();

          List<ProductImage> allImages = await apiAdminService
              .getImagesByProduct(_savedProduct!.id!);
          List<ProductImage> imagesToDelete =
              allImages
                  .where((img) => !currentImages.contains(img.image))
                  .toList();

          for (ProductImage image in imagesToDelete) {
            if (!mounted) return;
            try {
              if (image.id != null) {
                await apiAdminService.deleteProductImage(image.id!);
                developer.log(
                  "Deleted image with ID: ${image.id} (URL: ${image.image})",
                );
              }
            } catch (e) {
              throw Exception("Không thể xóa ảnh ${image.image}: $e");
            }
          }

          for (String imageUrl in imagesToAdd) {
            if (!mounted) return;
            ProductImage image = ProductImage(
              id: null,
              image: imageUrl,
              fkImageProduct: _savedProduct!.id!,
            );
            await apiAdminService.createProductImage(image);
          }
        } else {
          for (String imageUrl in _additionalImages) {
            if (!mounted) return;
            ProductImage image = ProductImage(
              id: null,
              image: imageUrl,
              fkImageProduct: _savedProduct!.id!,
            );
            await apiAdminService.createProductImage(image);
          }
        }
      }

      List<ProductVariant> updatedVariants = [];
      List<List<ProductColor>> updatedVariantColors = [];
      List<List<String?>> updatedColorImages = [];

      for (int i = 0; i < variants.length; i++) {
        if (!mounted) return;
        ProductVariant variantToSave = variants[i];

        if (variantToSave.nameVariant.isEmpty) {
          throw Exception("Tên biến thể không được để trống.");
        }
        if (variantToSave.importPrice == null ||
            variantToSave.importPrice! < 0) {
          throw Exception("Giá nhập không hợp lệ.");
        }
        if (variantToSave.originalPrice == null ||
            variantToSave.originalPrice! < 0) {
          throw Exception("Giá bán không hợp lệ.");
        }
        if (variantToSave.quantity == null || variantToSave.quantity! < 0) {
          throw Exception("Số lượng không hợp lệ.");
        }
        if (variantToSave.discountPercent == null ||
            variantToSave.discountPercent! < 0 ||
            variantToSave.discountPercent! > 100) {
          throw Exception("Phần trăm giảm giá không hợp lệ.");
        }
        if (variantToSave.discountPercent == null ||
            variantToSave.discountPercent! < 0 ||
            variantToSave.discountPercent! > 50) {
          throw Exception("Phần trăm giảm giá phải từ 0 đến 50%.");
        }

        if (variantToSave.id == 0) {
          variantToSave = ProductVariant(
            id: 0,
            nameVariant: variantToSave.nameVariant,
            importPrice: variantToSave.importPrice,
            originalPrice: variantToSave.originalPrice,
            quantity: variantToSave.quantity,
            discountPercent: variantToSave.discountPercent,
            price: _calculateFinalPrice(
              variantToSave.originalPrice,
              variantToSave.discountPercent,
            ),
            fkVariantProduct: _savedProduct!.id!,
          );
          var savedVariant = await apiAdminService.createProductVariant(
            variantToSave,
          );
          updatedVariants.add(savedVariant);
        } else {
          var updatedVariant = await apiAdminService.updateProductVariant(
            variantToSave.id,
            variantToSave,
          );
          updatedVariants.add(updatedVariant);
        }

        updatedVariantColors.add([]);
        updatedColorImages.add([]);
      }

      if (hasColors) {
        for (int i = 0; i < variants.length; i++) {
          for (int j = 0; j < variantColors[i].length; j++) {
            if (!mounted) return;
            var color = variantColors[i][j];

            if (color.colorName.isEmpty) {
              throw Exception("Tên màu không được để trống.");
            }
            if (color.colorPrice < 0) {
              throw Exception("Giá màu không hợp lệ.");
            }
            if (color.quantity == null || color.quantity! < 0) {
              throw Exception("Số lượng màu không hợp lệ.");
            }

            ProductColor colorToSave = ProductColor(
              id: color.id,
              colorName: color.colorName,
              colorPrice: color.colorPrice,
              quantity: color.quantity!,
              image: color.image,
              fkVariantProduct: updatedVariants[i].id,
            );

            if (color.id == 0) {
              var savedColor = await apiAdminService.createProductColor(
                colorToSave,
              );
              updatedVariantColors[i].add(savedColor);
              updatedColorImages[i].add(savedColor.image);
            } else {
              var updatedColor = await apiAdminService.updateProductColor(
                color.id,
                colorToSave,
              );
              updatedVariantColors[i].add(updatedColor);
              updatedColorImages[i].add(updatedColor.image);
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        variants = updatedVariants;
        variantColors = updatedVariantColors;
        colorImages = updatedColorImages;
        _updateInitialValues();
        _checkForChanges();
      });

      final product = {
        "id":
            _savedProduct!.id ?? "#00${DateTime.now().millisecondsSinceEpoch}",
        "name": _savedProduct!.name,
        "price":
            variants.isNotEmpty
                ? (hasColors &&
                        selectedVersionIndex >= 0 &&
                        selectedColorIndex >= 0 &&
                        variantColors[selectedVersionIndex].isNotEmpty
                    ? variantColors[selectedVersionIndex][selectedColorIndex]
                        .colorPrice
                    : variants[0].price)
                : 0,
        "quantity":
            variants.isNotEmpty
                ? (hasColors &&
                        selectedVersionIndex >= 0 &&
                        selectedColorIndex >= 0 &&
                        variantColors[selectedVersionIndex].isNotEmpty
                    ? variantColors[selectedVersionIndex][selectedColorIndex]
                        .quantity
                    : variants[0].quantity)
                : 0,
        "category": _savedProduct!.fkCategory,
        "brand": _savedProduct!.fkBrand,
        "image": _savedProduct!.mainImage,
        "versions": variants.map((v) => v.nameVariant).toList(),
        "versionColors":
            variantColors
                .map((colors) => colors.map((c) => c.colorName).toList())
                .toList(),
        "versionColorPrices":
            variantColors
                .map((colors) => colors.map((c) => c.colorPrice).toList())
                .toList(),
        "versionColorQuantities":
            variantColors
                .map((colors) => colors.map((c) => c.quantity).toList())
                .toList(),
        "specifications": specifications,
        "description": _savedProduct!.shortDescription,
        "additionalImages": _additionalImages,
      };

      if (mounted) {
        widget.onSave?.call(product);
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? "Cập nhật sản phẩm thành công"
                  : "Thêm sản phẩm thành công",
            ),
          ),
        );
        Navigator.pop(context); // Quay lại màn hình trước
      }
    } catch (e) {
      developer.log("Error saving product or variant: $e");
      if (mounted) {
        Navigator.pop(context); // Đóng dialog nếu lỗi
        setState(() {
          errorMessage = "Không thể lưu sản phẩm: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _deleteProduct() {
    if (widget.isEdit && widget.productInfo?.id != null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Xác nhận xóa"),
              content: Text(
                "Bạn có chắc chắn muốn xóa sản phẩm này? Tất cả biến thể và màu sắc liên quan sẽ bị xóa.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy"),
                ),
                TextButton(
                  onPressed: () async {
                    if (!mounted) return;
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    try {
                      await _deleteProductAndVariants();
                      if (mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Đã xóa sản phẩm thành công")),
                        );
                      }
                    } catch (e) {
                      developer.log("Error deleting product: $e");
                      if (mounted) {
                        setState(() {
                          errorMessage = "Không thể xóa sản phẩm: $e";
                        });
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Text("Xóa", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _deleteProductAndVariants() async {
    if (_savedProduct == null || _savedProduct!.id == null) {
      developer.log("No product to delete or invalid product ID");
      throw Exception(
        "Không có sản phẩm để xóa hoặc ID sản phẩm không hợp lệ.",
      );
    }
    try {
      for (var variant in variants) {
        if (variant.id != 0) {
          final colors = await apiAdminService.getColorsByVariantId(variant.id);
          for (var color in colors) {
            developer.log("Deleting color with ID: ${color.id}");
            await apiAdminService.deleteProductColor(color.id);
          }
          developer.log("Deleting variant with ID: ${variant.id}");
          await apiAdminService.deleteProductVariant(variant.id);
        }
      }
      developer.log("Deleting product with ID: ${_savedProduct!.id}");
      await apiAdminService.deleteProduct(_savedProduct!.id!);
      if (mounted) {
        setState(() {
          _savedProduct = null;
          variants.clear();
          variantColors.clear();
          colorImages.clear();
          selectedVersionIndex = -1;
          selectedColorIndex = -1;
          _updateInitialValues();
          _checkForChanges();
        });
      }
    } catch (e) {
      developer.log("Error deleting product and variants: $e");
      throw Exception("Lỗi khi xóa sản phẩm và biến thể: $e");
    }
  }

  void _showAddColorDialog() {
    if (selectedVersionIndex < 0 || !mounted) return;
    String? imagePath;
    if (variants[selectedVersionIndex].id == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Vui lòng lưu sản phẩm và phiên bản trước khi thêm màu.",
            ),
          ),
        );
      }
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("${variants[selectedVersionIndex].nameVariant}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProductImagePicker(
                      imageUrl: imagePath,
                      onImageChanged: (newUrl) {
                        setDialogState(() {
                          imagePath = newUrl;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newColorController,
                      decoration: InputDecoration(
                        labelText: "Tên màu",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: "Giá (VNĐ)",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newQuantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: "Số lượng",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_newColorController.text.isEmpty ||
                        _newPriceController.text.isEmpty ||
                        _newQuantityController.text.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Vui lòng nhập đầy đủ thông tin màu.",
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    final price = double.tryParse(_newPriceController.text);
                    final quantity = int.tryParse(_newQuantityController.text);
                    if (price == null || price < 0) {
                      if (mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text("Giá không hợp lệ.")),
                        );
                      }
                      return;
                    }
                    if (quantity == null || quantity < 0) {
                      if (mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text("Số lượng không hợp lệ.")),
                        );
                      }
                      return;
                    }
                    if (mounted) {
                      setState(() {
                        variantColors[selectedVersionIndex].add(
                          ProductColor(
                            id: 0,
                            colorName: _newColorController.text,
                            colorPrice: price,
                            quantity: quantity,
                            image: imagePath,
                            fkVariantProduct: variants[selectedVersionIndex].id,
                          ),
                        );
                        colorImages[selectedVersionIndex].add(imagePath);
                        if (selectedColorIndex == -1) selectedColorIndex = 0;
                        _updateColorControllers();
                        _checkForChanges();
                      });
                    }
                    _newColorController.clear();
                    _newPriceController.clear();
                    _newQuantityController.clear();
                    Navigator.pop(dialogContext);
                  },
                  child: Text("Hoàn tất", style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorChoiceDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Sản phẩm có màu sắc không?"),
            content: Text(
              "Bạn có muốn thêm màu sắc cho các phiên bản của sản phẩm này không?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      hasColors = true;
                      _checkForChanges();
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text("Có"),
              ),
              TextButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      hasColors = false;
                      _checkForChanges();
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text("Không"),
              ),
            ],
          ),
    );
  }

  void _showAddVersionDialog() {
    if (!mounted) return;
    final TextEditingController _finalPriceController = TextEditingController();

    void _updateFinalPrice() {
      final originalPrice =
          double.tryParse(_newVersionOriginalPriceController.text) ?? 0;
      int discountPercent =
          int.tryParse(_newVersionDiscountPercentController.text) ?? 0;

      if (discountPercent > 50) {
        discountPercent = 50;
        _newVersionDiscountPercentController.text = '50';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phần trăm giảm giá tối đa là 50%.")),
        );
      }

      final calculatedPrice = _calculateFinalPrice(
        originalPrice,
        discountPercent,
      );
      _finalPriceController.text = calculatedPrice.toStringAsFixed(0);
    }

    _newVersionOriginalPriceController.addListener(_updateFinalPrice);
    _newVersionDiscountPercentController.addListener(_updateFinalPrice);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Thêm phiên bản mới"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _newVersionController,
                      decoration: InputDecoration(
                        labelText: "Tên phiên bản (ví dụ: 1TB)",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newVersionImportPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: "Giá nhập (VNĐ)",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newVersionOriginalPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: "Giá bán (VNĐ)",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newVersionQuantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: "Số lượng",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _newVersionDiscountPercentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: "Số giảm (%)",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _finalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Tiền sau giảm (VNĐ)",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                      enabled: false,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    if (_newVersionController.text.isEmpty ||
                        _newVersionImportPriceController.text.isEmpty ||
                        _newVersionOriginalPriceController.text.isEmpty ||
                        _newVersionQuantityController.text.isEmpty ||
                        _newVersionDiscountPercentController.text.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Vui lòng nhập đầy đủ thông tin phiên bản.",
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    final importPrice = double.tryParse(
                      _newVersionImportPriceController.text,
                    );
                    final originalPrice = double.tryParse(
                      _newVersionOriginalPriceController.text,
                    );
                    final quantity = int.tryParse(
                      _newVersionQuantityController.text,
                    );
                    int discountPercent =
                        int.tryParse(
                          _newVersionDiscountPercentController.text,
                        ) ??
                        0;

                    if (importPrice == null || importPrice < 0) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Giá nhập không hợp lệ.")),
                        );
                      }
                      return;
                    }
                    if (originalPrice == null || originalPrice < 0) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Giá bán không hợp lệ.")),
                        );
                      }
                      return;
                    }
                    if (quantity == null || quantity < 0) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Số lượng không hợp lệ.")),
                        );
                      }
                      return;
                    }
                    if (discountPercent > 50) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Phần trăm giảm giá tối đa là 50%."),
                          ),
                        );
                      }
                      return;
                    }
                    if (discountPercent < 0) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Phần trăm giảm giá không hợp lệ."),
                          ),
                        );
                      }
                      return;
                    }
                    if (_nameController.text.isEmpty ||
                        selectedProductType == null ||
                        selectedBrand == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Vui lòng nhập đầy đủ thông tin sản phẩm trước khi thêm phiên bản.",
                            ),
                          ),
                        );
                      }
                      return;
                    }

                    if (mounted) {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                    }

                    try {
                      if (_savedProduct == null) {
                        ProductInfo productInfo = ProductInfo(
                          id: widget.isEdit ? widget.productInfo!.id : null,
                          name: _nameController.text,
                          fkCategory: selectedProductType!,
                          fkBrand: selectedBrand!,
                          mainImage: _imagePath,
                          shortDescription: _descriptionController.text,
                          detail: specifications
                              .map(
                                (spec) =>
                                    "${spec.keys.first}:${spec.values.first}",
                              )
                              .join(';'),
                          hasColor: false,
                        );

                        _savedProduct =
                            widget.isEdit
                                ? await apiAdminService.updateProduct(
                                  productInfo.id!,
                                  productInfo,
                                )
                                : await apiAdminService.createProduct(
                                  productInfo,
                                );
                        developer.log(
                          "Saved product with ID: ${_savedProduct!.id}",
                        );
                      }

                      final calculatedPrice = _calculateFinalPrice(
                        originalPrice,
                        discountPercent,
                      );
                      ProductVariant variantToSave = ProductVariant(
                        id: 0,
                        nameVariant: _newVersionController.text,
                        importPrice: importPrice,
                        originalPrice: originalPrice,
                        quantity: quantity,
                        discountPercent: discountPercent,
                        price: calculatedPrice,
                        fkVariantProduct: _savedProduct!.id!,
                      );

                      developer.log(
                        "Saving variant: ${variantToSave.toJson()}",
                      );
                      ProductVariant savedVariant = await apiAdminService
                          .createProductVariant(variantToSave);

                      if (mounted) {
                        setState(() {
                          variants.add(savedVariant);
                          variantColors.add([]);
                          colorImages.add([]);
                          selectedVersionIndex = variants.length - 1;
                          _updateVariantControllers();
                          _checkForChanges();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã thêm phiên bản thành công."),
                          ),
                        );
                        _newVersionController.clear();
                        _newVersionImportPriceController.clear();
                        _newVersionOriginalPriceController.clear();
                        _newVersionQuantityController.clear();
                        _newVersionDiscountPercentController.clear();
                        _finalPriceController.dispose();
                        Navigator.pop(dialogContext);
                        _showColorChoiceDialog();
                      }
                    } catch (e) {
                      developer.log("Error saving product or variant: $e");
                      if (mounted) {
                        setState(() {
                          errorMessage = "Không thể lưu phiên bản: $e";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Không thể lưu phiên bản: $e"),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Text("Hoàn tất", style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addSpecification() {
    if (!mounted) return;
    if (_valueController.text.isNotEmpty &&
        (showTitleInput ||
            (showKeyValueInput && _keyController.text.isNotEmpty))) {
      setState(() {
        Map<String, String> newSpec = {
          showTitleInput ? "Title" : _keyController.text: _valueController.text,
        };
        specifications.add(newSpec);
        _keyController.clear();
        _valueController.clear();
        showTitleInput = false;
        showKeyValueInput = false;
        _checkForChanges();
      });
    }
  }

  void _deleteVersion(int index) {
    if (!mounted) return;
    if (variants[index].id != 0) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text("Xác nhận xóa phiên bản"),
              content: Text(
                "Bạn có chắc chắn muốn xóa phiên bản '${variants[index].nameVariant}'? Tất cả màu sắc liên quan sẽ bị xóa.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Hủy"),
                ),
                TextButton(
                  onPressed: () async {
                    if (!mounted) return;
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    try {
                      if (variantColors[index].isNotEmpty) {
                        for (var color in variantColors[index]) {
                          if (color.id != 0) {
                            developer.log(
                              "Deleting color with ID: ${color.id}",
                            );
                            await apiAdminService.deleteProductColor(color.id);
                          }
                        }
                      }
                      developer.log(
                        "Deleting variant with ID: ${variants[index].id}",
                      );
                      await apiAdminService.deleteProductVariant(
                        variants[index].id,
                      );
                      if (mounted) {
                        setState(() {
                          variants.removeAt(index);
                          variantColors.removeAt(index);
                          colorImages.removeAt(index);
                          if (variants.isEmpty) {
                            selectedVersionIndex = -1;
                            selectedColorIndex = -1;
                          } else if (selectedVersionIndex >= variants.length) {
                            selectedVersionIndex = variants.length - 1;
                            selectedColorIndex =
                                variantColors[selectedVersionIndex].isEmpty
                                    ? -1
                                    : 0;
                          }
                          _updateVariantControllers();
                          _checkForChanges();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã xóa phiên bản thành công"),
                          ),
                        );
                        Navigator.pop(dialogContext);
                      }
                    } catch (e) {
                      developer.log("Error deleting variant: $e");
                      if (mounted) {
                        setState(() {
                          errorMessage = "Không thể xóa phiên bản: $e";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Không thể xóa phiên bản: $e"),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Text("Xóa", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );
    } else {
      if (mounted) {
        setState(() {
          variants.removeAt(index);
          variantColors.removeAt(index);
          colorImages.removeAt(index);
          if (variants.isEmpty) {
            selectedVersionIndex = -1;
            selectedColorIndex = -1;
          } else if (selectedVersionIndex >= variants.length) {
            selectedVersionIndex = variants.length - 1;
            selectedColorIndex =
                variantColors[selectedVersionIndex].isEmpty ? -1 : 0;
          }
          _updateVariantControllers();
          _checkForChanges();
        });
      }
    }
  }

  void _deleteColor(int index) {
    if (selectedVersionIndex < 0 || !mounted) return;
    if (variantColors[selectedVersionIndex].isEmpty ||
        index >= variantColors[selectedVersionIndex].length) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Không tìm thấy màu để xóa.")));
      }
      return;
    }
    if (variantColors[selectedVersionIndex][index].id != 0) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text("Xác nhận xóa màu"),
              content: Text(
                "Bạn có chắc chắn muốn xóa màu '${variantColors[selectedVersionIndex][index].colorName}'?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Hủy"),
                ),
                TextButton(
                  onPressed: () async {
                    if (!mounted) return;
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    try {
                      developer.log(
                        "Deleting color with ID: ${variantColors[selectedVersionIndex][index].id}",
                      );
                      await apiAdminService.deleteProductColor(
                        variantColors[selectedVersionIndex][index].id,
                      );
                      if (mounted) {
                        setState(() {
                          variantColors[selectedVersionIndex].removeAt(index);
                          if (selectedVersionIndex < colorImages.length &&
                              index <
                                  colorImages[selectedVersionIndex].length) {
                            colorImages[selectedVersionIndex].removeAt(index);
                          }
                          if (variantColors[selectedVersionIndex].isEmpty) {
                            selectedColorIndex = -1;
                          } else if (selectedColorIndex >=
                              variantColors[selectedVersionIndex].length) {
                            selectedColorIndex =
                                variantColors[selectedVersionIndex].length - 1;
                          }
                          _updateColorControllers();
                          _checkForChanges();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Đã xóa màu thành công")),
                        );
                        Navigator.pop(dialogContext);
                      }
                    } catch (e) {
                      developer.log("Error deleting color: $e");
                      if (mounted) {
                        setState(() {
                          errorMessage = "Không thể xóa màu: $e";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Không thể xóa màu: $e")),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Text("Xóa", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );
    } else {
      if (mounted) {
        setState(() {
          variantColors[selectedVersionIndex].removeAt(index);
          if (selectedVersionIndex < colorImages.length &&
              index < colorImages[selectedVersionIndex].length) {
            colorImages[selectedVersionIndex].removeAt(index);
          }
          if (variantColors[selectedVersionIndex].isEmpty) {
            selectedColorIndex = -1;
          } else if (selectedColorIndex >=
              variantColors[selectedVersionIndex].length) {
            selectedColorIndex = variantColors[selectedVersionIndex].length - 1;
          }
          _updateColorControllers();
          _checkForChanges();
        });
      }
    }
  }

  void _deleteSpecification(int index) {
    if (!mounted) return;
    setState(() {
      specifications.removeAt(index);
      _checkForChanges();
    });
  }

  double _calculateVersionPrice(int versionIndex) {
    return variants[versionIndex].price ?? 0;
  }

  double _calculateColorPrice(int versionIndex, int colorIndex) {
    return variantColors[versionIndex][colorIndex].colorPrice;
  }

  Future<bool> _handleBackNavigation() async {
    if (!widget.isEdit && _savedProduct != null) {
      bool? shouldCancel = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Xác nhận hủy"),
              content: Text(
                "Bạn đang thêm sản phẩm. Bạn có muốn hủy và xóa sản phẩm cùng các phiên bản vừa tạo không?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Không"),
                ),
                TextButton(
                  onPressed: () async {
                    await _deleteProductAndVariants();
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text("Có", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );
      return shouldCancel ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              bool shouldNavigate = await _handleBackNavigation();
              if (shouldNavigate && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          centerTitle: true,

          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,

          title: Text(
            "Chi tiết sản phẩm",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.message),
              tooltip: 'Tin nhắn',
              onPressed: () {
               final productId = _savedProduct?.id ?? widget.productInfo?.id;
               if (productId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductAdminPage(productId: productId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không tìm thấy ID sản phẩm')),
                );
              }
              },
            ),
          ],
        ),
        
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ProductImagePicker(
                        imageUrl: _imagePath,
                        onImageChanged: (newUrl) {
                          if (!mounted) return;
                          setState(() {
                            _imagePath = newUrl;
                            _checkForChanges();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ProductDetailImagePicker(
                        imageUrls: _additionalImages,
                        onImagesChanged: (newUrls) {
                          if (!mounted) return;
                          setState(() {
                            _additionalImages = newUrls;
                            _checkForChanges();
                          });
                        },
                        isEdit: widget.isEdit,
                        productId:
                            widget.isEdit ? widget.productInfo?.id : null,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Tên sản phẩm",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      productTypes.isEmpty
                          ? Text(
                            "Không có danh mục nào. Vui lòng kiểm tra API.",
                          )
                          : DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            value:
                                productTypes.contains(selectedProductType) &&
                                        selectedProductType != null
                                    ? selectedProductType
                                    : productTypes.first,
                            decoration: InputDecoration(
                              labelText: "Loại sản phẩm",
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                            items:
                                productTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (!mounted) return;
                              setState(() {
                                selectedProductType = newValue;
                                _checkForChanges();
                              });
                            },
                          ),
                      SizedBox(height: 16),
                      brands.isEmpty
                          ? Text("Không có hãng nào. Vui lòng kiểm tra API.")
                          : DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            value:
                                brands.contains(selectedBrand) &&
                                        selectedBrand != null
                                    ? selectedBrand
                                    : brands.first,
                            decoration: InputDecoration(
                              labelText: "Hãng",
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                            items:
                                brands.map((String brand) {
                                  return DropdownMenuItem<String>(
                                    value: brand,
                                    child: Text(brand),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (!mounted) return;
                              setState(() {
                                selectedBrand = newValue;
                                _checkForChanges();
                              });
                            },
                          ),
                      SizedBox(height: 16),
                      Text(
                        "Mô tả sản phẩm:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: "Mô tả",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Thông tin chi tiết:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: [
                          if (!showTitleInput && !showKeyValueInput)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (!mounted) return;
                                    setState(() {
                                      showTitleInput = true;
                                      _checkForChanges();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Nhập Tiêu đề'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (!mounted) return;
                                    setState(() {
                                      showKeyValueInput = true;
                                      _checkForChanges();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Nhập đề mục'),
                                ),
                              ],
                            ),
                          if (showTitleInput) ...[
                            TextField(
                              controller: _valueController,
                              decoration: InputDecoration(
                                labelText: 'Nhập nội dung tiêu đề',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                          if (showKeyValueInput)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _keyController,
                                    decoration: InputDecoration(
                                      labelText: 'Nhập đề mục',
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                      floatingLabelStyle: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _valueController,
                                    decoration: InputDecoration(
                                      labelText: 'Nhập nội dung',
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                      floatingLabelStyle: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (showTitleInput || showKeyValueInput) ...[
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addSpecification,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Hoàn tất'),
                            ),
                          ],
                          SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: specifications.length,
                              itemBuilder: (context, index) {
                                Map<String, String> spec =
                                    specifications[index];
                                String key = spec.keys.first;
                                String value = spec.values.first;
                                bool isTitle = key.toLowerCase() == 'title';
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child:
                                          isTitle
                                              ? Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 5,
                                                ),
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                              : Container(
                                                color:
                                                    index % 2 == 0
                                                        ? Colors.grey[100]
                                                        : Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 8,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        key,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap:
                                            () => _deleteSpecification(index),
                                        child: Container(
                                          color: Colors.red,
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Chọn phiên bản:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: _showAddVersionDialog,
                            child: Text(
                              "Thêm phiên bản",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      variants.isEmpty
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEdit
                                    ? "Không tìm thấy phiên bản nào"
                                    : "Chưa có phiên bản nào",
                                style: TextStyle(
                                  color:
                                      widget.isEdit ? Colors.red : Colors.grey,
                                ),
                              ),
                              if (widget.isEdit)
                                TextButton(
                                  onPressed: _fetchVariants,
                                  child: Text("Thử lại"),
                                ),
                            ],
                          )
                          : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(variants.length, (index) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (!mounted) return;
                                      setState(() {
                                        selectedVersionIndex = index;
                                        selectedColorIndex =
                                            hasColors &&
                                                    variantColors[index]
                                                        .isNotEmpty
                                                ? 0
                                                : -1;
                                        _updateVariantControllers();
                                        _updateColorControllers();
                                      });
                                    },
                                    child: Container(
                                      width: 110,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              selectedVersionIndex == index
                                                  ? Colors.blue
                                                  : Colors.grey,
                                          width:
                                              selectedVersionIndex == index
                                                  ? 2
                                                  : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            variants[index].nameVariant ??
                                                'N/A',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text(
                                          //   "${ConvertMoney.currencyFormatter.format(_calculateVersionPrice(index))} ₫",
                                          //   style: TextStyle(fontSize: 12),
                                          // ),
                                          // Text(
                                          //   "SL: ${variants[index].quantity ?? 0}",
                                          //   style: TextStyle(
                                          //     fontSize: 12,
                                          //     color: Colors.grey,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => _deleteVersion(index),
                                      child: Container(
                                        color: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                      if ((!hasColors ||
                              (hasColors &&
                                  selectedVersionIndex >= 0 &&
                                  selectedVersionIndex < variantColors.length &&
                                  variantColors[selectedVersionIndex]
                                      .isEmpty)) &&
                          widget.isEdit &&
                          selectedVersionIndex >= 0 &&
                          selectedVersionIndex < variants.length) ...[
                        SizedBox(height: 16),
                        Text(
                          "Thông tin biến thể:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _variantImportPriceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: "Giá nhập (VNĐ)",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                onChanged: (value) => _updateVariant(),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _variantOriginalPriceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: "Giá bán (VNĐ)",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (value) => _updateVariant(),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _variantQuantityController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: "Số lượng",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (value) => _updateVariant(),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _variantDiscountPercentController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: "Số giảm (%)",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                onChanged: (value) => _updateVariant(),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _variantPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Tiền sau giảm (VNĐ)",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (hasColors &&
                          selectedVersionIndex >= 0 &&
                          selectedVersionIndex < variants.length &&
                          selectedVersionIndex < variantColors.length) ...[
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Màu sắc:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _showAddColorDialog,
                              child: Text(
                                "Thêm màu",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        variantColors[selectedVersionIndex].isEmpty
                            ? Text("Chưa có màu nào cho phiên bản này")
                            : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(
                                variantColors[selectedVersionIndex].length,
                                (index) {
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (!mounted) return;
                                          setState(() {
                                            selectedColorIndex = index;
                                            _updateColorControllers();
                                          });
                                        },
                                        child: IntrinsicWidth(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    selectedColorIndex == index
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                width:
                                                    selectedColorIndex == index
                                                        ? 2
                                                        : 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  variantColors[selectedVersionIndex][index]
                                                      .colorName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // Text(
                                                //   "${ConvertMoney.currencyFormatter.format(_calculateColorPrice(selectedVersionIndex, index))} ₫",
                                                //   style: TextStyle(
                                                //     fontSize: 12,
                                                //   ),
                                                // ),
                                                // Text(
                                                //   "SL: ${variantColors[selectedVersionIndex][index].quantity}",
                                                //   style: TextStyle(
                                                //     fontSize: 12,
                                                //     color: Colors.grey,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () => _deleteColor(index),
                                          child: Container(
                                            color: Colors.red,
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        if (selectedColorIndex >= 0 &&
                            selectedVersionIndex >= 0 &&
                            selectedVersionIndex < variants.length &&
                            selectedVersionIndex < variantColors.length &&
                            selectedColorIndex <
                                variantColors[selectedVersionIndex].length) ...[
                          SizedBox(height: 16),
                          Text(
                            "Thông tin màu sắc:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (variantColors[selectedVersionIndex][selectedColorIndex]
                                        .image !=
                                    null)
                                  Center(
                                    child: Image.network(
                                      variantColors[selectedVersionIndex][selectedColorIndex]
                                          .image!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                SizedBox(height: 8),
                                TextField(
                                  controller: _colorNameController,
                                  decoration: InputDecoration(
                                    labelText: "Tên màu",
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2.0,
                                      ),
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) => _updateColor(),
                                ),
                                SizedBox(height: 8),
                                TextField(
                                  controller: _colorPriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Giá bán (VNĐ)",
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2.0,
                                      ),
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) => _updateColor(),
                                ),
                                SizedBox(height: 8),
                                TextField(
                                  controller: _colorQuantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Số lượng",
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2.0,
                                      ),
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) => _updateColor(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.isEdit)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "Xóa",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              if (widget.isEdit) SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveProduct : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges ? Colors.blue : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    widget.isEdit ? "Cập nhật" : "Thêm",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ProductVariantExtension on ProductVariant {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameVariant': nameVariant,
      'importPrice': importPrice,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'discountPercent': discountPercent,
      'price': price,
      'fkVariantProduct': fkVariantProduct,
    };
  }
}

extension ProductColorExtension on ProductColor {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colorName': colorName,
      'colorPrice': colorPrice,
      'quantity': quantity,
      'image': image,
      'fkVariantProduct': fkVariantProduct,
    };
  }
}
