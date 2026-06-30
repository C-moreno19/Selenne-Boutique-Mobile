import 'package:flutter/material.dart';

enum SnackType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    String? title,
    SnackType type = SnackType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color bg;
    final IconData icon;

    switch (type) {
      case SnackType.error:
        bg = const Color(0xFFB02A37);
        icon = Icons.error_outline_rounded;
        break;
      case SnackType.info:
        bg = const Color(0xFF444444);
        icon = Icons.info_outline_rounded;
        break;
      case SnackType.success:
        bg = const Color(0xFFd65391);
        icon = Icons.check_rounded;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: title != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          Text(message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12)),
                        ],
                      )
                    : Text(message,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
              ),
            ],
          ),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          elevation: 6,
          duration: duration,
        ),
      );
  }
}
