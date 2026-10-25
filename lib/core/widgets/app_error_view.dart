import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_primary_button.dart';

/// Standardized recoverable error view with action button.
class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.actionLabel = 'Try Again',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: AppRadii.borderFull,
              ),
              child: Icon(icon, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral700),
            ),
            if (onRetry != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.space24),
              AppPrimaryButton(
                label: actionLabel!,
                onPressed: onRetry,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
