import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            icon,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                icon.contains('google')
                    ? Icons.g_mobiledata
                    : Icons.facebook,
                size: 28,
                color: AppColors.textPrimary,
              );
            },
          ),
        ),
      ),
    );
  }
}