import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeType { active, warning, alert, inactive }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  Color get _backgroundColor {
    switch (type) {
      case BadgeType.active:
        return AppColors.success.withValues(alpha: 0.15);
      case BadgeType.warning:
        return AppColors.warning.withValues(alpha: 0.15);
      case BadgeType.alert:
        return AppColors.alertRed.withValues(alpha: 0.15);
      case BadgeType.inactive:
        return AppColors.textSecondary.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.active:
        return AppColors.success;
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.alert:
        return AppColors.alertRed;
      case BadgeType.inactive:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
