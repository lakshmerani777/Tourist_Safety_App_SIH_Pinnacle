import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SafetyButtonVariant { primary, danger, outlined }

class SafetyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SafetyButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  const SafetyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = SafetyButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case SafetyButtonVariant.outlined:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentBlue,
              side: const BorderSide(color: AppColors.accentBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _buildChild(AppColors.accentBlue),
          ),
        );
      case SafetyButtonVariant.danger:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _buildChild(AppColors.textPrimary),
          ),
        );
      case SafetyButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.accentBlue.withValues(alpha: 0.4),
              disabledForegroundColor: AppColors.textPrimary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _buildChild(AppColors.textPrimary),
          ),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}
