import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Form input text field with accessible labels, errors, prefix/suffix widgets.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool enabled;
  final int maxLines;
  final String? helperText;
  final String? prefixText;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.helperText,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          style: AppTypography.bodyMedium.copyWith(
            color: enabled ? AppColors.neutral900 : AppColors.neutral600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            prefixStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w600,
            ),
            errorText: errorText,
            helperText: helperText,
            filled: true,
            fillColor: enabled ? AppColors.surfaceWhite : AppColors.neutral100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadii.border8,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.border8,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.border8,
              borderSide: const BorderSide(color: AppColors.brandNavy, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadii.border8,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
