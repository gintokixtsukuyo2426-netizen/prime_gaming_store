import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import '../utils/product_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final IsarService _isarService = IsarService();
  Map<String, dynamic> _stats = {
    'totalProducts': 0,
    'totalStock': 0,
    'totalValue': 0,
  };
  List<Product> _lowStockProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshStats();
  }

  Future<void> refreshStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final stats = await _isarService.getStats();
    final products = await _isarService.getAllProducts();
    final lowStock = products.where((p) => p.stock <= 5).toList();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _lowStockProducts = lowStock;
      _isLoading = false;
    });
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
        title: Text(
          'Prime Gaming Store',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: refreshStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshStats,
        color: const Color(0xFF6C63FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Ringkasan inventaris toko kamu',
                style: TextStyle(color: subColor, fontSize: 14),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : Column(
                      children: [
                        _StatCard(
                          icon: Icons.category_rounded,
                          label: 'Total Produk',
                          value: '${_stats['totalProducts']} item',
                          color: const Color(0xFF6C63FF),
                          cardColor: cardColor,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          icon: Icons.inventory_rounded,
                          label: 'Total Stok',
                          value: '${_stats['totalStock']} unit',
                          color: const Color(0xFF00C9A7),
                          cardColor: cardColor,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Nilai Inventaris',
                          value: _formatRupiah(_stats['totalValue']),
                          color: const Color(0xFFFF6B6B),
                          cardColor: cardColor,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                      ],
                    ),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFFB347),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stok Menipis',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _lowStockProducts.isEmpty
                            ? const Color(0xFF00C9A7).withValues(alpha: 0.15)
                            : const Color(0xFFFFB347).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_lowStockProducts.length}',
                        style: TextStyle(
                          color: _lowStockProducts.isEmpty
                              ? const Color(0xFF00C9A7)
                              : const Color(0xFFFFB347),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              _isLoading
                  ? const SizedBox()
                  : _lowStockProducts.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00C9A7)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF00C9A7)),
                              SizedBox(width: 10),
                              Text(
                                'Semua stok produk aman!',
                                style: TextStyle(
                                    color: Color(0xFF00C9A7),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _lowStockProducts
                              .map((p) => _LowStockCard(
                                    product: p,
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    subColor: subColor,
                                  ))
                              .toList(),
                        ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gunakan tab di bawah untuk navigasi antar halaman!',
                        style: TextStyle(color: subColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: subColor, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final Product product;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const _LowStockCard({
    required this.product,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  Color get _stockColor {
    if (product.stock == 0) return const Color(0xFFFF6B6B);
    return const Color(0xFFFFB347);
  }

  String get _stockLabel {
    if (product.stock == 0) return 'Habis';
    return 'Sisa ${product.stock}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _stockColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Gambar Produk
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _stockColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ProductImage(
                imagePath: product.imagePath,
                fit: BoxFit.cover,
                placeholder: Icon(
                  product.stock == 0
                      ? Icons.remove_circle_rounded
                      : Icons.warning_rounded,
                  color: _stockColor,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.category,
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _stockColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _stockLabel,
              style: TextStyle(
                color: _stockColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}