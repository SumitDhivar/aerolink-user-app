import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;

  // Controllers
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);
    bool success = false;

    if (_isSignUp) {
      final phone = _phoneController.text.trim();
      final fullPhone = phone.startsWith('+') ? phone : '+91$phone';
      success = await controller.register(
        phone: fullPhone,
        displayName: _displayNameController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      );
    } else {
      success = await controller.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      context.go(RouteNames.home);
    } else {
      final authState = ref.read(authControllerProvider);
      if (authState is Unauthenticated && authState.message != null) {
        setState(() => _errorMessage = authState.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.space24),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.brandNavy,
                        borderRadius: AppRadii.border16,
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        color: AppColors.brandAmber,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'AeroLink Passenger',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(color: AppColors.neutral900),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    _isSignUp
                        ? 'Create your account for CSMIA ride pooling'
                        : 'Sign in with your registered phone or email',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600),
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  // Mode Selector Segmented Tab
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: AppRadii.border8,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
                              decoration: BoxDecoration(
                                color: !_isSignUp ? AppColors.surfaceWhite : Colors.transparent,
                                borderRadius: AppRadii.border8,
                                boxShadow: !_isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Sign In',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge.copyWith(
                                  color: !_isSignUp ? AppColors.brandNavy : AppColors.neutral700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
                              decoration: BoxDecoration(
                                color: _isSignUp ? AppColors.surfaceWhite : Colors.transparent,
                                borderRadius: AppRadii.border8,
                                boxShadow: _isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Register',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge.copyWith(
                                  color: _isSignUp ? AppColors.brandNavy : AppColors.neutral700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadii.border8,
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.space8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                  ],

                  if (_isSignUp) ...[
                    AppTextField(
                      label: 'Full Name',
                      hint: 'e.g. Sumit Dhivar',
                      controller: _displayNameController,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.neutral600),
                      validator: (v) {
                        if (v == null || v.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space16),
                  ],

                  AppTextField(
                    label: _isSignUp ? 'Mobile Phone' : 'Phone or Email',
                    hint: _isSignUp ? '9876543210' : 'e.g. +919876543210 or rider@example.com',
                    controller: _phoneController,
                    prefixText: _isSignUp ? '+91 ' : null,
                    keyboardType: _isSignUp ? TextInputType.phone : TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.neutral600),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.space16),

                  if (_isSignUp) ...[
                    AppTextField(
                      label: 'Email (Optional)',
                      hint: 'rider@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.neutral600),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                  ],

                  AppTextField(
                    label: 'Password',
                    hint: 'Minimum 8 characters',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.neutral600),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.neutral600,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  AppPrimaryButton(
                    label: _isSignUp ? 'Create Passenger Account' : 'Sign In',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.space16),

                  Text(
                    'By continuing, you agree to AeroLink\'s Terms of Service and Privacy Policy for Greater Mumbai pilot operations.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
