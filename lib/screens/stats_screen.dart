import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final IsarService _isarService = IsarService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final products = await _isarService.getAllProducts();
    setState(() {
      _products = products;
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

  Map<String, int> get _categoryStock {
    final map = <String, int>{};
    for (final p in _products) {
      map[p.category] = (map[p.category] ?? 0) + p.stock;
    }
    return map;
  }

  Map<String, int> get _categoryValue {
    final map = <String, int>{};
    for (final p in _products) {
      map[p.category] = (map[p.category] ?? 0) + (p.price * p.stock);
    }
    return map;
  }

  int get _totalValue {
    return _products.fold(0, (sum, p) => sum + (p.price * p.stock));
  }

  int get _totalStock {
    return _products.fold(0, (sum, p) => sum + p.stock);
  }

  List<Product> get _lowStockProducts {
    return _products.where((p) => p.stock <= 5).toList();
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
          'Statistik',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _products.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada data produk',
                    style: TextStyle(color: subColor, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF6C63FF),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Inventaris',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStatCard(
                                label: 'Total Produk',
                                value: '${_products.length}',
                                icon: Icons.category_rounded,
                                color: const Color(0xFF6C63FF),
                                cardColor: cardColor,
                                subColor: subColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStatCard(
                                label: 'Total Stok',
                                value: '$_totalStock',
                                icon: Icons.inventory_rounded,
                                color: const Color(0xFF00C9A7),
                                cardColor: cardColor,
                                subColor: subColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _MiniStatCard(
                          label: 'Total Nilai Inventaris',
                          value: _formatRupiah(_totalValue),
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFFFFB347),
                          cardColor: cardColor,
                          subColor: subColor,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 28),

                        Text(
                          'Persentase Stok per Kategori',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildCategoryBars(textColor),
                        const SizedBox(height: 28),

                        Text(
                          'Nilai Inventaris per Kategori',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildValueBars(textColor),
                        const SizedBox(height: 28),

                        if (_lowStockProducts.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.warning_rounded,
                                  color: Color(0xFFFFB347), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Stok Menipis (≤ 5)',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._lowStockProducts.map(
                            (p) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFB347)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          p.category,
                                          style: TextStyle(
                                              color: subColor, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: p.stock == 0
                                          ? const Color(0xFFFF6B6B)
                                              .withValues(alpha: 0.2)
                                          : const Color(0xFFFFB347)
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Stok: ${p.stock}',
                                      style: TextStyle(
                                        color: p.stock == 0
                                            ? const Color(0xFFFF6B6B)
                                            : const Color(0xFFFFB347),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  List<Widget> _buildCategoryBars(Color textColor) {
    final catStock = _categoryStock;
    final total = _totalStock == 0 ? 1 : _totalStock;
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00C9A7),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFF4FC3F7),
      const Color(0xFFCE93D8),
      const Color(0xFF80CBC4),
      const Color(0xFFF48FB1),
    ];
    int colorIndex = 0;
    return catStock.entries.map((entry) {
      final percent = (entry.value / total * 100).toStringAsFixed(1);
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key,
                    style: TextStyle(color: textColor, fontSize: 13)),
                Text(
                  '$percent% (${entry.value} unit)',
                  style: TextStyle(color: color, fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: entry.value / total,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildValueBars(Color textColor) {
    final catValue = _categoryValue;
    final maxVal = catValue.values.isEmpty
        ? 1
        : catValue.values.reduce((a, b) => a > b ? a : b);
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00C9A7),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFF4FC3F7),
      const Color(0xFFCE93D8),
    ];
    int colorIndex = 0;
    return catValue.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key,
                    style: TextStyle(color: textColor, fontSize: 13)),
                Text(
                  _formatRupiah(entry.value),
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: entry.value / maxVal,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color cardColor;
  final Color subColor;
  final bool fullWidth;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.cardColor,
    required this.subColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: subColor, fontSize: 11)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}