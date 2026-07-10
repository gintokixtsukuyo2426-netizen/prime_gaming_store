import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'transaction_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<TransactionScreenState> _transactionKey =
      GlobalKey<TransactionScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(key: _dashboardKey),
      const ProductListScreen(),
      TransactionScreen(key: _transactionKey),
      const StatsScreen(),
      const SettingsScreen(),
      const AboutScreen(),
    ];
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _dashboardKey.currentState?.refreshStats();
    } else if (index == 2) {
      _transactionKey.currentState?.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          backgroundColor: const Color(0xFF1A1A2E),
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_rounded),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_rounded),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}