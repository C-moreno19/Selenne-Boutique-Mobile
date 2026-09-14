import 'dart:convert';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  final String src;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;

  const AdaptiveImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderWidget = placeholder ??
        Image.asset(
          'assets/images/placeholders/placeholder.png',
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: Colors.grey.shade200,
            width: width,
            height: height,
            child: const Center(child: Icon(Icons.image_outlined, size: 30)),
          ),
        );

    // Defensive normalization: handle empty, backslashes and leading ./ or /
    var s = src.trim();
    s = s.replaceAll('\\', '/'); // Windows paths -> asset style
    if (s.startsWith('./')) s = s.substring(2);
    if (s.startsWith('/')) s = s.substring(1);

    if (s.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: placeholderWidget,
      );
    }

    if (s.startsWith('http') || s.startsWith('https')) {
      return Image.network(
        s,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (c, e, s) => placeholderWidget,
      );
    }

    // Data URLs (base64)
    if (s.startsWith('data:image')) {
      try {
        final parts = s.split(',');
        if (parts.length > 1) {
          final base64Str = parts.sublist(1).join(',');
          final bytes = base64Decode(base64Str);
          return Image.memory(bytes, width: width, height: height, fit: fit);
        }
      } catch (_) {
        return placeholderWidget;
      }
    }

    // Treat remaining strings as asset paths
    return Image.asset(
      s,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (c, e, s) => placeholderWidget,
    );
  }
}
