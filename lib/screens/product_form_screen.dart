<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import '../utils/product_image.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final IsarService _isarService = IsarService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  String _selectedCategory = 'Mouse';
  bool _isLoading = false;
  File? _imageFile;

  final List<String> _categories = [
    'Mouse', 'Keyboard', 'Headset', 'Controller',
    'Monitor', 'Voucher Game', 'Aksesoris', 'Lainnya',
  ];

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    if (_isEditMode && _categories.contains(widget.product!.category)) {
      _selectedCategory = widget.product!.category;
    }
    // Tidak load _imageFile dari imagePath karena bisa berupa asset
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final product = widget.product ?? Product();
    product.name = _nameController.text.trim();
    product.category = _selectedCategory;
    product.price = int.parse(_priceController.text.trim());
    product.stock = int.parse(_stockController.text.trim());
    product.description = _descController.text.trim();
    // Kalau user pilih gambar baru dari galeri, pakai itu
    // Kalau tidak, pertahankan imagePath lama (bisa berupa asset atau file)
    if (_imageFile != null) {
      product.imagePath = _imageFile!.path;
    } else {
      product.imagePath = widget.product?.imagePath ?? '';
    }

    if (_isEditMode) {
      await _isarService.updateProduct(product);
    } else {
      await _isarService.addProduct(product);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Produk berhasil diperbarui!'
              : 'Produk berhasil ditambahkan!'),
          backgroundColor: const Color(0xFF00C9A7),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Produk' : 'Tambah Produk',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: _imageFile != null
                      // Kalau user sudah pilih gambar baru dari galeri
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      // Kalau ada gambar lama (asset atau file lama)
                      : widget.product != null &&
                              widget.product!.imagePath.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ProductImage(
                                    imagePath: widget.product!.imagePath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.6),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit_rounded,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Ganti',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          // Belum ada gambar sama sekali
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 48),
                                const SizedBox(height: 8),
                                Text('Tap untuk pilih gambar dari galeri',
                                    style: TextStyle(
                                        color: subColor, fontSize: 13)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Nama Produk', textColor),
              _buildTextField(
                controller: _nameController,
                hint: 'Contoh: Mouse Razer DeathAdder',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                validator: (val) =>
                    val!.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Kategori', textColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 15),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                            value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Harga (Rp)', textColor),
              _buildTextField(
                controller: _priceController,
                hint: 'Contoh: 850000',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                    val!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Stok', textColor),
              _buildTextField(
                controller: _stockController,
                hint: 'Contoh: 10',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                    val!.isEmpty ? 'Stok wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Deskripsi', textColor),
              _buildTextField(
                controller: _descController,
                hint: 'Deskripsi singkat produk...',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                maxLines: 4,
                validator: (val) =>
                    val!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode ? 'Simpan Perubahan' : 'Tambah Produk',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subColor),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
    );
  }
=======
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import '../utils/product_image.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final IsarService _isarService = IsarService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  String _selectedCategory = 'Mouse';
  bool _isLoading = false;
  File? _imageFile;

  final List<String> _categories = [
    'Mouse', 'Keyboard', 'Headset', 'Controller',
    'Monitor', 'Voucher Game', 'Aksesoris', 'Lainnya',
  ];

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    if (_isEditMode && _categories.contains(widget.product!.category)) {
      _selectedCategory = widget.product!.category;
    }
    // Tidak load _imageFile dari imagePath karena bisa berupa asset
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final product = widget.product ?? Product();
    product.name = _nameController.text.trim();
    product.category = _selectedCategory;
    product.price = int.parse(_priceController.text.trim());
    product.stock = int.parse(_stockController.text.trim());
    product.description = _descController.text.trim();
    // Kalau user pilih gambar baru dari galeri, pakai itu
    // Kalau tidak, pertahankan imagePath lama (bisa berupa asset atau file)
    if (_imageFile != null) {
      product.imagePath = _imageFile!.path;
    } else {
      product.imagePath = widget.product?.imagePath ?? '';
    }

    if (_isEditMode) {
      await _isarService.updateProduct(product);
    } else {
      await _isarService.addProduct(product);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Produk berhasil diperbarui!'
              : 'Produk berhasil ditambahkan!'),
          backgroundColor: const Color(0xFF00C9A7),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Produk' : 'Tambah Produk',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: _imageFile != null
                      // Kalau user sudah pilih gambar baru dari galeri
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      // Kalau ada gambar lama (asset atau file lama)
                      : widget.product != null &&
                              widget.product!.imagePath.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ProductImage(
                                    imagePath: widget.product!.imagePath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.6),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit_rounded,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Ganti',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          // Belum ada gambar sama sekali
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 48),
                                const SizedBox(height: 8),
                                Text('Tap untuk pilih gambar dari galeri',
                                    style: TextStyle(
                                        color: subColor, fontSize: 13)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Nama Produk', textColor),
              _buildTextField(
                controller: _nameController,
                hint: 'Contoh: Mouse Razer DeathAdder',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                validator: (val) =>
                    val!.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Kategori', textColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 15),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                            value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Harga (Rp)', textColor),
              _buildTextField(
                controller: _priceController,
                hint: 'Contoh: 850000',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                    val!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Stok', textColor),
              _buildTextField(
                controller: _stockController,
                hint: 'Contoh: 10',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                    val!.isEmpty ? 'Stok wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Deskripsi', textColor),
              _buildTextField(
                controller: _descController,
                hint: 'Deskripsi singkat produk...',
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
                maxLines: 4,
                validator: (val) =>
                    val!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode ? 'Simpan Perubahan' : 'Tambah Produk',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subColor),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
    );
  }
>>>>>>> 9b4bb509a7b1889b3d30e46da9dfed0349681c1e
}