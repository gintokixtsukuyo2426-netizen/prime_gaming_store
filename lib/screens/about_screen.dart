import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.gamepad_rounded,
                  size: 65, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 16),
            Text(
              'Prime Gaming Store',
              style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Versi 1.0.0',
              style: TextStyle(color: subColor, fontSize: 13),
            ),
            const SizedBox(height: 32),

            _InfoSection(
              title: 'Pembuat Aplikasi',
              cardColor: cardColor,
              textColor: textColor,
              subColor: subColor,
              items: const [
                _InfoRowData(label: 'Nama', value: 'Nama Mahasiswa'),
                _InfoRowData(label: 'NIM', value: 'NIM Mahasiswa'),
                _InfoRowData(label: 'Prodi', value: 'D4 Bisnis Digital'),
                _InfoRowData(label: 'Mata Kuliah', value: 'Mobile Programming'),
              ],
            ),
            const SizedBox(height: 16),

            _InfoSection(
              title: 'Tentang Aplikasi',
              cardColor: cardColor,
              textColor: textColor,
              subColor: subColor,
              items: const [
                _InfoRowData(
                    label: 'Fungsi',
                    value: 'Manajemen inventaris toko gaming'),
                _InfoRowData(label: 'Platform', value: 'Android'),
                _InfoRowData(label: 'Framework', value: 'Flutter & Dart'),
                _InfoRowData(label: 'Database', value: 'Isar (Local)'),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Aplikasi',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Splash Screen & Onboarding',
                    'Login Admin & Manajemen Akun',
                    'Dashboard dengan Statistik',
                    'CRUD Produk Gaming + Upload Gambar',
                    'Pencarian Produk',
                    'Transaksi Penjualan & Riwayat',
                    'Statistik & Persentase Inventaris',
                    'Pengaturan, Dark/Light Mode & Reset Data',
                    'Database Lokal dengan Isar',
                  ].map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF00C9A7), size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(f,
                                style:
                                    TextStyle(color: subColor, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2025 Prime Gaming Store\nD4 Bisnis Digital',
              textAlign: TextAlign.center,
              style: TextStyle(color: subColor, fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRowData {
  final String label;
  final String value;
  const _InfoRowData({required this.label, required this.value});
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRowData> items;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const _InfoSection({
    required this.title,
    required this.items,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label,
                        style: TextStyle(color: subColor, fontSize: 13)),
                    Text(item.value,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}