import 'dart:io';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  bool get _isAsset => imagePath.startsWith('assets/');
  bool get _isFile => imagePath.isNotEmpty && !_isAsset;

  Widget get _placeholder =>
      placeholder ??
      const Icon(
        Icons.gamepad_rounded,
        color: Color(0xFF6C63FF),
        size: 32,
      );

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return _placeholder;

    if (_isAsset) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder,
      );
    }

    if (_isFile) {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder,
      );
    }

    return _placeholder;
  }
}