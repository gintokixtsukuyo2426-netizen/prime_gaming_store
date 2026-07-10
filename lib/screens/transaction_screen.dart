import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/product.dart';
import '../models/sales_transaction.dart';
import '../providers/theme_provider.dart';
import '../utils/product_image.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IsarService _isarService = IsarService();

  List<Product> _products = [];
  List<SalesTransaction> _transactions = [];
  Map<String, dynamic> _salesStats = {
    'totalTransactions': 0,
    'totalRevenue': 0,
    'totalItems': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final products = await _isarService.getAllProducts();
    final transactions = await _isarService.getAllTransactions();
    final stats = await _isarService.getAllTimeSalesStats();
    if (!mounted) return;
    setState(() {
      _products = products;
      _transactions = transactions;
      _salesStats = stats;
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }

  Widget _buildTransactionImage(int productId) {
    Product? matchedProduct;
    for (final p in _products) {
      if (p.id == productId) {
        matchedProduct = p;
        break;
      }
    }

    if (matchedProduct != null && matchedProduct.imagePath.isNotEmpty) {
      return ProductImage(
        imagePath: matchedProduct.imagePath,
        fit: BoxFit.cover,
        placeholder: const Icon(
          Icons.shopping_cart_checkout_rounded,
          color: Color(0xFF00C9A7),
          size: 20,
        ),
      );
    }

    return const Icon(
      Icons.shopping_cart_checkout_rounded,
      color: Color(0xFF00C9A7),
      size: 20,
    );
  }

  void _showSellDialog(Product product, bool isDark) {
    final qtyController = TextEditingController(text: '1');
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final fieldColor =
        isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              'Jual: ${product.name}',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stok tersedia: ${product.stock}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  'Harga: ${_formatRupiah(product.price)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Total: ${_formatRupiah(product.price * (int.tryParse(qtyController.text) ?? 1))}',
                  style: const TextStyle(
                    color: Color(0xFF00C9A7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal',
                    style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () async {
                  final qty = int.tryParse(qtyController.text) ?? 0;
                  if (qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Jumlah harus lebih dari 0'),
                        backgroundColor: Color(0xFFFF6B6B),
                      ),
                    );
                    return;
                  }
                  if (qty > product.stock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stok tidak cukup!'),
                        backgroundColor: Color(0xFFFF6B6B),
                      ),
                    );
                    return;
                  }
                  final success = await _isarService.createTransaction(
                    product: product,
                    quantity: qty,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaksi berhasil!'),
                          backgroundColor: Color(0xFF00C9A7),
                        ),
                      );
                      refreshData();
                    }
                  }
                },
                child: const Text('Jual',
                    style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
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
          'Transaksi Penjualan',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: subColor,
          tabs: const [
            Tab(text: 'Jual Produk'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSellTab(cardColor, textColor, subColor, isDark),
                _buildHistoryTab(cardColor, textColor, subColor, isDark),
              ],
            ),
    );
  }

  Widget _buildSellTab(
      Color cardColor, Color textColor, Color subColor, bool isDark) {
    if (_products.isEmpty) {
      return Center(
        child: Text(
          'Belum ada produk.\nTambahkan produk dulu di tab Produk.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subColor, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      color: const Color(0xFF6C63FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final isOutOfStock = product.stock == 0;

          return Container(
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
                Container(
                  width: 50,
                  height: 50,
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
                        size: 26,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatRupiah(product.price)} • Stok: ${product.stock}',
                        style: TextStyle(
                          color: isOutOfStock
                              ? const Color(0xFFFF6B6B)
                              : subColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isOutOfStock
                      ? null
                      : () => _showSellDialog(product, isDark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C9A7),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.grey.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: Text(isOutOfStock ? 'Habis' : 'Jual'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(
      Color cardColor, Color textColor, Color subColor, bool isDark) {
    return RefreshIndicator(
      onRefresh: refreshData,
      color: const Color(0xFF6C63FF),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Transaksi',
                    value: '${_salesStats['totalTransactions']}',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF6C63FF),
                    cardColor: cardColor,
                    subColor: subColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Item Terjual',
                    value: '${_salesStats['totalItems']}',
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFF00C9A7),
                    cardColor: cardColor,
                    subColor: subColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SummaryCard(
              label: 'Total Pendapatan',
              value: _formatRupiah(_salesStats['totalRevenue']),
              icon: Icons.payments_rounded,
              color: const Color(0xFFFFB347),
              cardColor: cardColor,
              subColor: subColor,
              fullWidth: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Belum ada transaksi',
                    style: TextStyle(color: subColor),
                  ),
                ),
              )
            else
              ..._transactions.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C9A7)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildTransactionImage(t.productId),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.productName,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${t.quantity}x @ ${_formatRupiah(t.pricePerItem)}',
                                style:
                                    TextStyle(color: subColor, fontSize: 11),
                              ),
                              Text(
                                _formatDate(t.date),
                                style:
                                    TextStyle(color: subColor, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatRupiah(t.totalPrice),
                          style: const TextStyle(
                            color: Color(0xFF00C9A7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color cardColor;
  final Color subColor;
  final bool fullWidth;

  const _SummaryCard({
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: subColor, fontSize: 11)),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}