import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuImage extends StatelessWidget {
  final String imageBase64;
  final String imageUrl;
  final String imagePath;
  final String category;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MenuImage({
    super.key,
    this.imageBase64 = '',
    this.imageUrl = '',
    this.imagePath = '',
    required this.category,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  IconData _categoryIcon() {
    switch (category) {
      case 'drink':
        return Icons.local_cafe_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'snack':
        return Icons.cake_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F1E7), Color(0xFF95D5B2)],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          _categoryIcon(),
          size: 48,
          color: const Color(0xFF6B7D1F),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageBase64.isNotEmpty) {
      // Prioritas 1: upload dari admin (base64)
      image = Image.memory(
        Uri.parse(imageBase64).data!.contentAsBytes(),
        width: width,
        height: height,
        fit: fit,
      );
    } else if (imageUrl.isNotEmpty) {
      // Prioritas 2: URL dari internet
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    } else if (imagePath.isNotEmpty) {
      // Prioritas 3: assets lokal
      image = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      // Fallback: placeholder emoji
      return _placeholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}
