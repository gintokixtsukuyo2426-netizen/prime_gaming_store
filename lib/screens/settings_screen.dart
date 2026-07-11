<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/isar_service.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import '../utils/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Pengaturan',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilan
            Text('TAMPILAN',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                title: Text('Mode Gelap',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(isDark ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(color: subColor, fontSize: 12)),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: const Color(0xFF6C63FF),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Aplikasi
            Text('APLIKASI',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.gamepad_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Prime Gaming Store',
                subtitle: 'Versi 1.0.0',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFF00C9A7),
                title: 'Platform',
                subtitle: 'Android',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.storage_rounded,
                iconColor: const Color(0xFFFFB347),
                title: 'Database',
                subtitle: 'Isar Local Database',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
            ]),
            const SizedBox(height: 24),

            // Manajemen Data
            Text('MANAJEMEN DATA',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.delete_forever_rounded,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Reset Semua Data',
                subtitle: 'Hapus seluruh produk dari database',
                trailing: Icon(Icons.chevron_right, color: subColor),
                textColor: textColor,
                subColor: subColor,
                onTap: () => _resetData(context, isDark),
              ),
            ]),
            const SizedBox(height: 24),

            // Akun
            Text('AKUN',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.lock_reset_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Ganti Password',
                subtitle: 'Ubah password akun admin',
                trailing: Icon(Icons.chevron_right, color: subColor),
                textColor: textColor,
                subColor: subColor,
                onTap: () => _showChangePasswordDialog(context, isDark),
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Logout',
                subtitle: 'Keluar dari akun admin',
                trailing: Icon(Icons.chevron_right, color: subColor),
                textColor: textColor,
                subColor: subColor,
                onTap: () => _logout(context, isDark),
              ),
            ]),
            const SizedBox(height: 24),

            // Teknologi
            Text('TEKNOLOGI',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF4FC3F7),
                title: 'Flutter',
                subtitle: 'UI Framework',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.data_object_rounded,
                iconColor: const Color(0xFFCE93D8),
                title: 'Dart',
                subtitle: 'Programming Language',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.folder_rounded,
                iconColor: const Color(0xFF80CBC4),
                title: 'Isar Database',
                subtitle: 'Local Storage',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _resetData(BuildContext context, bool isDark) async {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Reset Data', style: TextStyle(color: textColor)),
        content: Text(
            'Data produk akan dikembalikan ke bawaan project. Lanjutkan?',
            style: TextStyle(color: Colors.grey.shade500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final service = IsarService();
      await service.clearProducts();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data produk bawaan berhasil dikembalikan'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  void _logout(BuildContext context, bool isDark) async {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Logout', style: TextStyle(color: textColor)),
        content: Text('Yakin ingin keluar?',
            style: TextStyle(color: Colors.grey.shade500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
  context,
  AppRouter.fade(const LoginScreen()),
  (route) => false,
);
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final fieldColor =
        isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);

    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Ganti Password', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PassField(
                controller: oldPassController,
                hint: 'Password lama',
                fillColor: fieldColor),
            const SizedBox(height: 10),
            _PassField(
                controller: newPassController,
                hint: 'Password baru',
                fillColor: fieldColor),
            const SizedBox(height: 10),
            _PassField(
                controller: confirmPassController,
                hint: 'Konfirmasi password baru',
                fillColor: fieldColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru tidak cocok!'),
                    backgroundColor: Color(0xFFFF6B6B),
                  ),
                );
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              final username = prefs.getString('logged_username') ?? 'admin';
              final success = await IsarService().changePassword(
                username: username,
                oldPassword: oldPassController.text,
                newPassword: newPassController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Password berhasil diubah!'
                        : 'Password lama salah!'),
                    backgroundColor: success
                        ? const Color(0xFF00C9A7)
                        : const Color(0xFFFF6B6B),
                  ),
                );
              }
            },
            child: const Text('Simpan',
                style: TextStyle(
                    color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color fillColor;

  const _PassField({
    required this.controller,
    required this.hint,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor;

  const _SettingCard({required this.children, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.textColor,
    required this.subColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle:
          Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
      trailing: trailing,
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/isar_service.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import '../utils/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Pengaturan',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilan
            Text('TAMPILAN',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                title: Text('Mode Gelap',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(isDark ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(color: subColor, fontSize: 12)),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: const Color(0xFF6C63FF),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Aplikasi
            Text('APLIKASI',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.gamepad_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Prime Gaming Store',
                subtitle: 'Versi 1.0.0',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFF00C9A7),
                title: 'Platform',
                subtitle: 'Android',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.storage_rounded,
                iconColor: const Color(0xFFFFB347),
                title: 'Database',
                subtitle: 'Isar Local Database',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
            ]),
            const SizedBox(height: 24),

            // Manajemen Data
            Text('MANAJEMEN DATA',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.delete_forever_rounded,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Reset Semua Data',
                subtitle: 'Hapus seluruh produk dari database',
                trailing: Icon(Icons.chevron_right, color: subColor),
                textColor: textColor,
                subColor: subColor,
                onTap: () => _resetData(context, isDark),
              ),
            ]),
            const SizedBox(height: 24),

            // Akun
            Text('AKUN',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.lock_reset_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Ganti Password',
                subtitle: 'Ubah password akun admin',
                trailing: Icon(Icons.chevron_right, color: subColor),
                textColor: textColor,
                subColor: subColor,
                onTap: () => _showChangePasswordDialog(context, isDark),
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Logout',
                subtitle: 'Keluar dari akun admin',
                trailing: Icon(Icons.chevron_right, color: subColor),
                textColor: textColor,
                subColor: subColor,
                onTap: () => _logout(context, isDark),
              ),
            ]),
            const SizedBox(height: 24),

            // Teknologi
            Text('TEKNOLOGI',
                style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            _SettingCard(cardColor: cardColor, children: [
              _SettingItem(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF4FC3F7),
                title: 'Flutter',
                subtitle: 'UI Framework',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.data_object_rounded,
                iconColor: const Color(0xFFCE93D8),
                title: 'Dart',
                subtitle: 'Programming Language',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              _SettingItem(
                icon: Icons.folder_rounded,
                iconColor: const Color(0xFF80CBC4),
                title: 'Isar Database',
                subtitle: 'Local Storage',
                trailing: const SizedBox(),
                textColor: textColor,
                subColor: subColor,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _resetData(BuildContext context, bool isDark) async {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Reset Data', style: TextStyle(color: textColor)),
        content: Text(
            'Data produk akan dikembalikan ke bawaan project. Lanjutkan?',
            style: TextStyle(color: Colors.grey.shade500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final service = IsarService();
      await service.clearProducts();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data produk bawaan berhasil dikembalikan'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  void _logout(BuildContext context, bool isDark) async {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Logout', style: TextStyle(color: textColor)),
        content: Text('Yakin ingin keluar?',
            style: TextStyle(color: Colors.grey.shade500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
  context,
  AppRouter.fade(const LoginScreen()),
  (route) => false,
);
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final fieldColor =
        isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2F5);

    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Ganti Password', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PassField(
                controller: oldPassController,
                hint: 'Password lama',
                fillColor: fieldColor),
            const SizedBox(height: 10),
            _PassField(
                controller: newPassController,
                hint: 'Password baru',
                fillColor: fieldColor),
            const SizedBox(height: 10),
            _PassField(
                controller: confirmPassController,
                hint: 'Konfirmasi password baru',
                fillColor: fieldColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru tidak cocok!'),
                    backgroundColor: Color(0xFFFF6B6B),
                  ),
                );
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              final username = prefs.getString('logged_username') ?? 'admin';
              final success = await IsarService().changePassword(
                username: username,
                oldPassword: oldPassController.text,
                newPassword: newPassController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Password berhasil diubah!'
                        : 'Password lama salah!'),
                    backgroundColor: success
                        ? const Color(0xFF00C9A7)
                        : const Color(0xFFFF6B6B),
                  ),
                );
              }
            },
            child: const Text('Simpan',
                style: TextStyle(
                    color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color fillColor;

  const _PassField({
    required this.controller,
    required this.hint,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor;

  const _SettingCard({required this.children, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.textColor,
    required this.subColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle:
          Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
      trailing: trailing,
    );
  }
}
>>>>>>> 9b4bb509a7b1889b3d30e46da9dfed0349681c1e
