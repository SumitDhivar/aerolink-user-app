import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/flight_status.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  final String direction;
  final String terminal;
  final String mode;
  final double lat;
  final double lng;
  final String label;

  const FlightSearchScreen({
    super.key,
    required this.direction,
    required this.terminal,
    required this.mode,
    required this.lat,
    required this.lng,
    required this.label,
  });

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  final _flightNumberController = TextEditingController(text: '6E 204');
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  FlightStatus? _flightStatus;
  String? _lookupError;

  @override
  void dispose() {
    _flightNumberController.dispose();
    super.dispose();
  }

  Future<void> _searchFlight() async {
    final flightNum = _flightNumberController.text.trim().replaceAll(' ', '');
    if (flightNum.isEmpty) return;

    setState(() {
      _isLoading = true;
      _lookupError = null;
    });

    final repo = ref.read(flightRepositoryProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final result = await repo.getFlightStatus(
      flightNumber: flightNum,
      flightDate: dateStr,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (status) {
        setState(() => _flightStatus = status);
      },
      failure: (err) {
        setState(() {
          _lookupError = err.message;
          _flightStatus = null;
        });
      },
    );
  }

  void _proceedToReview() {
    final flightNum = _flightStatus?.flightNumber ?? _flightNumberController.text.trim();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    context.push(
      '${RouteNames.journeyReview}?'
      'direction=${widget.direction}&'
      'terminal=${widget.terminal}&'
      'mode=${widget.mode}&'
      'lat=${widget.lat}&'
      'lng=${widget.lng}&'
      'label=${Uri.encodeComponent(widget.label)}&'
      'flight=${Uri.encodeComponent(flightNum)}&'
      'flightDate=$dateStr',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Flight Context'),
        actions: [
          TextButton(
            onPressed: _proceedToReview,
            child: const Text('Skip', style: TextStyle(color: AppColors.surfaceWhite)),
          ),
        ],
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
                      Row(
                        children: [
                          const Icon(Icons.flight_outlined, color: AppColors.brandNavy, size: 24),
                          const SizedBox(width: AppSpacing.space8),
                          Text(
                            'Enter Flight Details',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Text(
                        'Linking your flight allows automatic adjustment for arrival delays and protects your departure check-in window.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      AppTextField(
                        label: 'Flight Number',
                        hint: 'e.g. 6E 204 or AI 101',
                        controller: _flightNumberController,
                        prefixIcon: const Icon(Icons.airplane_ticket_outlined),
                      ),
                      const SizedBox(height: AppSpacing.space12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today_rounded, size: 18),
                              label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 2)),
                                  lastDate: DateTime.now().add(const Duration(days: 14)),
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                            ),
                            onPressed: _isLoading ? null : _searchFlight,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Lookup'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              if (_lookupError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: AppRadii.border8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: Text(
                          'Live flight data unavailable for this date. You can still proceed with manual scheduling.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
              ],

              if (_flightStatus != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _flightStatus!.flightNumber,
                              style: AppTypography.titleLarge.copyWith(color: AppColors.brandNavy),
                            ),
                            AppStatusBadge(
                              label: _flightStatus!.status,
                              variant: _flightStatus!.status == 'landed' || _flightStatus!.status == 'active'
                                  ? BadgeVariant.success
                                  : BadgeVariant.info,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        const Divider(color: AppColors.neutral200),
                        const SizedBox(height: AppSpacing.space12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Terminal', style: AppTypography.bodySmall),
                                Text(_flightStatus!.terminal ?? 'T2', style: AppTypography.labelLarge),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gate', style: AppTypography.bodySmall),
                                Text(_flightStatus!.gate ?? '--', style: AppTypography.labelLarge),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Est. Arrival', style: AppTypography.bodySmall),
                                Text(
                                  _flightStatus!.estimatedArrival != null
                                      ? DateFormat('HH:mm').format(_flightStatus!.estimatedArrival!)
                                      : 'On Time',
                                  style: AppTypography.labelLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          'Source: ${_flightStatus!.source} • Freshness: ${_flightStatus!.freshness}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
              ],

              AppPrimaryButton(
                label: 'Continue to Fare Review',
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                onPressed: _proceedToReview,
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
