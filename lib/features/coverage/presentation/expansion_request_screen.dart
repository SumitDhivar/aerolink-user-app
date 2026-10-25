import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../domain/coverage_result.dart';

class ExpansionRequestScreen extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;
  final String direction;
  final String label;

  const ExpansionRequestScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.direction,
    required this.label,
  });

  @override
  ConsumerState<ExpansionRequestScreen> createState() => _ExpansionRequestScreenState();
}

class _ExpansionRequestScreenState extends ConsumerState<ExpansionRequestScreen> {
  bool _consent = false;
  bool _isSubmitting = false;
  String _timeWindow = 'Morning (06:00 - 12:00)';
  String? _submittedRequestId;

  Future<void> _submit() async {
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the consent checkbox to submit.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = ref.read(coverageRepositoryProvider);

    final req = ExpansionRequest(
      location: LocationInput(
        coordinates: Coordinates(
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
        confirmedPin: true,
        placeId: widget.label,
      ),
      direction: widget.direction,
      requestedTimeWindow: _timeWindow,
      consent: true,
    );

    final result = await repo.submitExpansionRequest(req);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (reqId) {
        setState(() => _submittedRequestId = reqId);
      },
      failure: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedRequestId != null) {
      return Scaffold(
        backgroundColor: AppColors.softNeutral,
        appBar: AppBar(title: const Text('Request Received')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                const SizedBox(height: AppSpacing.space16),
                Text(
                  'Expansion Request Logged',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.neutral900),
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Your area demand has been recorded under reference #$_submittedRequestId. We analyze aggregate requests during CSMIA corridor expansion planning.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral700),
                ),
                const SizedBox(height: AppSpacing.space32),
                AppPrimaryButton(
                  label: 'Return to Home',
                  onPressed: () => context.go(RouteNames.home),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Request Corridor Coverage'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested Area Location',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.brandNavy, size: 20),
                          const SizedBox(width: AppSpacing.space8),
                          Expanded(
                            child: Text(
                              widget.label,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'Coordinates: (${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)})',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Typical Travel Window',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      DropdownButtonFormField<String>(
                        initialValue: _timeWindow,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: AppRadii.border8),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Morning (06:00 - 12:00)',
                            child: Text('Morning (06:00 - 12:00)'),
                          ),
                          DropdownMenuItem(
                            value: 'Afternoon (12:00 - 18:00)',
                            child: Text('Afternoon (12:00 - 18:00)'),
                          ),
                          DropdownMenuItem(
                            value: 'Evening (18:00 - 00:00)',
                            child: Text('Evening (18:00 - 00:00)'),
                          ),
                          DropdownMenuItem(
                            value: 'Late Night (00:00 - 06:00)',
                            child: Text('Late Night (00:00 - 06:00)'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _timeWindow = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Mandatory Consent per FR-ZONE-011
              CheckboxListTile(
                value: _consent,
                activeColor: AppColors.brandNavy,
                onChanged: (val) => setState(() => _consent = val ?? false),
                title: Text(
                  'I acknowledge that submitting this expansion request does not guarantee or immediately activate service in this area.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral800),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.space24),

              AppPrimaryButton(
                label: 'Submit Expansion Request',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
