import 'dart:io';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final double iconSize;
  final Color iconColor;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.fallbackIcon = Icons.gamepad_rounded,
    this.iconSize = 32,
    this.iconColor = const Color(0xFF6C63FF),
    this.fit = BoxFit.cover,
  });

  bool get _isAsset => imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return _fallback();

    if (_isAsset) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return Image.file(
      File(imagePath),
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Icon(fallbackIcon, color: iconColor, size: iconSize);
  }
}
