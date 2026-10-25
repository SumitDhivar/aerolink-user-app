import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

enum BadgeVariant { success, warning, error, info, neutral }

/// Accessible status badge combining an icon and high-contrast label.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (fg, bg, defaultIcon) = switch (variant) {
      BadgeVariant.success => (AppColors.success, AppColors.successContainer, Icons.check_circle_rounded),
      BadgeVariant.warning => (AppColors.warning, AppColors.warningContainer, Icons.warning_rounded),
      BadgeVariant.error => (AppColors.error, AppColors.errorContainer, Icons.cancel_rounded),
      BadgeVariant.info => (AppColors.info, AppColors.infoContainer, Icons.info_rounded),
      BadgeVariant.neutral => (AppColors.neutral700, AppColors.neutral100, Icons.circle),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.borderFull,
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? defaultIcon, size: 14, color: fg),
          const SizedBox(width: AppSpacing.space4),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
