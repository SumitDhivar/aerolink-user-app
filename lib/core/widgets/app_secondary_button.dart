import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Secondary action button (Teal or Outlined Navy).
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.space48,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brandNavy,
            disabledForegroundColor: AppColors.neutral500,
            side: BorderSide(
              color: enabled ? AppColors.brandNavy : AppColors.neutral300,
              width: 1.5,
            ),
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.border8),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          ),
          child: _buildContent(AppColors.brandNavy),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandTeal,
          foregroundColor: AppColors.surfaceWhite,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral500,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.border8),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        ),
        child: _buildContent(AppColors.surfaceWhite),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.space8),
        ],
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(color: textColor),
        ),
      ],
    );
  }
}
