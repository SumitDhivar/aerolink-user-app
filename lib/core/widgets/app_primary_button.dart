import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Primary action button (Deep Navy) with loading, disabled, and icon states.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = AppSpacing.space48,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final bg = backgroundColor ?? AppColors.brandNavy;
    final fg = foregroundColor ?? AppColors.surfaceWhite;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral500,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.border8),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surfaceWhite),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.space8),
                  ],
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: enabled ? fg : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
