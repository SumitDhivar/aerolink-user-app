import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/incident_models.dart';

class SafetySupportScreen extends ConsumerStatefulWidget {
  const SafetySupportScreen({super.key});

  @override
  ConsumerState<SafetySupportScreen> createState() => _SafetySupportScreenState();
}

class _SafetySupportScreenState extends ConsumerState<SafetySupportScreen> {
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'safety';
  String _selectedSeverity = 'critical';
  bool _isSubmitting = false;
  IncidentResponse? _submittedIncident;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _reportIncident() async {
    final desc = _descriptionController.text.trim();
    if (desc.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the issue in at least 5 characters.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = ref.read(incidentRepositoryProvider);

    final req = IncidentCreateRequest(
      category: _selectedCategory,
      description: desc,
      severity: _selectedSeverity,
      source: 'passenger',
    );

    final result = await repo.reportIncident(req);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (incident) {
        setState(() => _submittedIncident = incident);
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
    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Safety & Emergency (SOS)'),
        backgroundColor: AppColors.error,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency SOS Banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadii.border12,
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_rounded, color: AppColors.error, size: 28),
                        SizedBox(width: AppSpacing.space12),
                        Expanded(
                          child: Text(
                            'Immediate Emergency Alert',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'If you or anyone in the vehicle is in immediate physical danger, dial 112 (National Emergency Services) directly. Submitting a critical incident here triggers immediate automated trip pausing and 24/7 responder escalation.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.neutral900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space20),

              if (_submittedIncident != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space20),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          'Safety Incident Logged',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          'Case Reference: #${_submittedIncident!.id.substring(0, 8).toUpperCase()}',
                          style: AppTypography.labelLarge.copyWith(color: AppColors.brandNavy),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          'Status: ${_submittedIncident!.status.toUpperCase()} • Severity: ${_submittedIncident!.severity.toUpperCase()}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral700),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        Text(
                          'Automated trip safeguards and evidence preservation have been initiated per safety protocol.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space20),
              ],

              // Report New Incident Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report an Issue or Safety Incident',
                        style: AppTypography.titleSmall.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space12),

                      Text('Incident Category', style: AppTypography.labelMedium),
                      const SizedBox(height: AppSpacing.space8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'safety', child: Text('Safety Threat / Harassment')),
                          DropdownMenuItem(value: 'driver', child: Text('Driver Conduct / Reckless Driving')),
                          DropdownMenuItem(value: 'route', child: Text('Unauthorized Route Detour')),
                          DropdownMenuItem(value: 'payment', child: Text('Payment / Fare Discrepancy')),
                          DropdownMenuItem(value: 'operational', child: Text('Vehicle Breakdown / Delay')),
                        ],
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      Text('Severity Level', style: AppTypography.labelMedium),
                      const SizedBox(height: AppSpacing.space8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSeverity,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'critical', child: Text('Critical (Immediate Escalation)')),
                          DropdownMenuItem(value: 'high', child: Text('High Priority')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                          DropdownMenuItem(value: 'low', child: Text('Low Priority / Inquiry')),
                        ],
                        onChanged: (v) => setState(() => _selectedSeverity = v!),
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      AppTextField(
                        label: 'Describe what happened',
                        hint: 'Provide details about the incident, location, or vehicle...',
                        controller: _descriptionController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSpacing.space20),

                      AppPrimaryButton(
                        label: 'Submit Safety Report',
                        backgroundColor: AppColors.error,
                        isLoading: _isSubmitting,
                        onPressed: _reportIncident,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
