import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import '../utils/app_router.dart';
import '../utils/product_image.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final IsarService _isarService = IsarService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua', 'Mouse', 'Keyboard', 'Headset', 'Controller',
    'Monitor', 'Voucher Game', 'Aksesoris', 'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _isarService.getProductsFiltered(
      query: _searchController.text,
      category: _selectedCategory,
    );
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _applyFilter() async {
    final results = await _isarService.getProductsFiltered(
      query: _searchController.text,
      category: _selectedCategory,
    );
    setState(() => _products = results);
  }

  Future<void> _deleteProduct(Product product, bool isDark) async {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Hapus Produk', style: TextStyle(color: textColor)),
        content: Text('Yakin ingin menghapus "${product.name}"?',
            style: TextStyle(color: Colors.grey.shade500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _isarService.deleteProduct(product.id);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
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
        title: Text('Daftar Produk',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6C63FF), size: 28),
            onPressed: () async {
              await Navigator.push(
                context,
                AppRouter.slideUp(const ProductFormScreen()),
              );
              _loadProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar + Filter Dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilter(),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(color: subColor),
                      prefixIcon: Icon(Icons.search, color: subColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: subColor),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedCategory != 'Semua'
                        ? Border.all(
                            color: const Color(0xFF6C63FF)
                                .withValues(alpha: 0.5))
                        : null,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: _selectedCategory != 'Semua'
                            ? const Color(0xFF6C63FF)
                            : subColor,
                        size: 20,
                      ),
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor, fontSize: 13),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                      color: cat == _selectedCategory
                                          ? const Color(0xFF6C63FF)
                                          : textColor),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedCategory = val!);
                        _applyFilter();
                      },
                      selectedItemBuilder: (context) {
                        return _categories.map((cat) {
                          return Icon(
                            Icons.filter_list_rounded,
                            color: _selectedCategory != 'Semua'
                                ? const Color(0xFF6C63FF)
                                : subColor,
                            size: 20,
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chip indikator filter aktif
          if (_selectedCategory != 'Semua')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCategory,
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = 'Semua');
                            _applyFilter();
                          },
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF6C63FF), size: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Product List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF)))
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 80, color: subColor),
                            const SizedBox(height: 16),
                            Text('Belum ada produk',
                                style: TextStyle(
                                    color: subColor, fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  AppRouter.slideUp(
                                      const ProductFormScreen()),
                                );
                                _loadProducts();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Produk'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: const Color(0xFF6C63FF),
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return _ProductCard(
                              product: product,
                              cardColor: cardColor,
                              textColor: textColor,
                              subColor: subColor,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  AppRouter.slideUp(
                                    ProductDetailScreen(product: product),
                                  ),
                                );
                                _loadProducts();
                              },
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  AppRouter.slideUp(
                                    ProductFormScreen(product: product),
                                  ),
                                );
                                _loadProducts();
                              },
                              onDelete: () =>
                                  _deleteProduct(product, isDark),
                              formatRupiah: _formatRupiah,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(int) formatRupiah;

  const _ProductCard({
    required this.product,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.formatRupiah,
  });

  Color get _stockColor {
    if (product.stock == 0) return const Color(0xFFFF6B6B);
    if (product.stock <= 5) return const Color(0xFFFFB347);
    return const Color(0xFF00C9A7);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Gambar Produk
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImage(
                  imagePath: product.imagePath,
                  fit: BoxFit.cover,
                  placeholder: const Icon(
                    Icons.gamepad_rounded,
                    color: Color(0xFF6C63FF),
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(product.category,
                      style: TextStyle(color: subColor, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        formatRupiah(product.price),
                        style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _stockColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stok: ${product.stock}',
                          style: TextStyle(
                              color: _stockColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded,
                      color: Color(0xFF00C9A7), size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded,
                      color: Color(0xFFFF6B6B), size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}