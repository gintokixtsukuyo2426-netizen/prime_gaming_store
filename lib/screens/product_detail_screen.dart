import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import '../utils/app_router.dart';
import '../utils/product_image.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
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

  Color get _stockColor {
    if (_product.stock == 0) return const Color(0xFFFF6B6B);
    if (_product.stock <= 5) return const Color(0xFFFFB347);
    return const Color(0xFF00C9A7);
  }

  String get _stockLabel {
    if (_product.stock == 0) return 'Habis';
    if (_product.stock <= 5) return 'Hampir Habis';
    return 'Tersedia';
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
        title: Text('Detail Produk',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF00C9A7)),
            onPressed: () async {
              await Navigator.push(
                context,
                AppRouter.slideUp(ProductFormScreen(product: _product)),
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: ProductImage(
                    imagePath: _product.imagePath,
                    fit: BoxFit.cover,
                    placeholder: const Icon(
                      Icons.gamepad_rounded,
                      size: 80,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nama & Kategori
            Center(
              child: Column(
                children: [
                  Text(
                    _product.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _product.category,
                      style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Info Cards
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Harga',
                    value: _formatRupiah(_product.price),
                    icon: Icons.price_change_rounded,
                    color: const Color(0xFF6C63FF),
                    cardColor: cardColor,
                    subColor: subColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Stok',
                    value: '${_product.stock} unit',
                    icon: Icons.inventory_rounded,
                    color: _stockColor,
                    cardColor: cardColor,
                    subColor: subColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status Stok
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _stockColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _stockColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _product.stock == 0
                        ? Icons.remove_circle_rounded
                        : _product.stock <= 5
                            ? Icons.warning_rounded
                            : Icons.check_circle_rounded,
                    color: _stockColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Status: $_stockLabel',
                    style: TextStyle(
                        color: _stockColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Nilai Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFB347).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Color(0xFFFFB347), size: 20),
                      const SizedBox(width: 8),
                      Text('Nilai Total Stok',
                          style: TextStyle(color: subColor, fontSize: 13)),
                    ],
                  ),
                  Text(
                    _formatRupiah(_product.price * _product.stock),
                    style: const TextStyle(
                        color: Color(0xFFFFB347),
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Deskripsi
            Text('Deskripsi',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _product.description.isEmpty
                    ? 'Tidak ada deskripsi.'
                    : _product.description,
                style: TextStyle(
                    color: subColor, fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Edit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    AppRouter.slideUp(ProductFormScreen(product: _product)),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit Produk',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color cardColor;
  final Color subColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.cardColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: subColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}