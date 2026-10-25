import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_primary_button.dart';

class PlanRideScreen extends ConsumerStatefulWidget {
  final String initialDirection;

  const PlanRideScreen({
    super.key,
    this.initialDirection = 'airport_arrival',
  });

  @override
  ConsumerState<PlanRideScreen> createState() => _PlanRideScreenState();
}

class _PlanRideScreenState extends ConsumerState<PlanRideScreen> {
  late String _direction;
  String _selectedTerminal = 'T2';
  String _selectedBay = 'Level P4 West (Bays W1-W6)';
  String _bookingMode = 'on_demand';

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
  }

  @override
  Widget build(BuildContext context) {
    final isArrival = _direction == 'airport_arrival';

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Airport Direction & Terminal'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Direction Toggle Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journey Direction',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('From CSMIA (Arrival)'),
                              selected: isArrival,
                              onSelected: (val) {
                                if (val) setState(() => _direction = 'airport_arrival');
                              },
                              selectedColor: AppColors.brandNavy,
                              labelStyle: AppTypography.labelMedium.copyWith(
                                color: isArrival ? AppColors.surfaceWhite : AppColors.neutral700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('To CSMIA (Departure)'),
                              selected: !isArrival,
                              onSelected: (val) {
                                if (val) setState(() => _direction = 'airport_departure');
                              },
                              selectedColor: AppColors.brandTeal,
                              labelStyle: AppTypography.labelMedium.copyWith(
                                color: !isArrival ? AppColors.surfaceWhite : AppColors.neutral700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Terminal Selection Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArrival ? 'CSMIA Pickup Terminal' : 'CSMIA Departure Terminal',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'Commercial ride-pool pickup is designated per airport authority regulations.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      InkWell(
                        onTap: () => setState(() => _selectedTerminal = 'T2'),
                        borderRadius: AppRadii.border8,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.space12),
                          decoration: BoxDecoration(
                            color: _selectedTerminal == 'T2'
                                ? AppColors.brandNavy.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: AppRadii.border8,
                            border: Border.all(
                              color: _selectedTerminal == 'T2'
                                  ? AppColors.brandNavy
                                  : AppColors.neutral300,
                              width: _selectedTerminal == 'T2' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedTerminal == 'T2'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _selectedTerminal == 'T2'
                                    ? AppColors.brandNavy
                                    : AppColors.neutral500,
                              ),
                              const SizedBox(width: AppSpacing.space12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Terminal 2 (Sahar)', style: AppTypography.labelLarge),
                                    Text(
                                      'International & Domestic Flights • App-Cab Pickup: Level P4',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      InkWell(
                        onTap: () => setState(() => _selectedTerminal = 'T1'),
                        borderRadius: AppRadii.border8,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.space12),
                          decoration: BoxDecoration(
                            color: _selectedTerminal == 'T1'
                                ? AppColors.brandNavy.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: AppRadii.border8,
                            border: Border.all(
                              color: _selectedTerminal == 'T1'
                                  ? AppColors.brandNavy
                                  : AppColors.neutral300,
                              width: _selectedTerminal == 'T1' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedTerminal == 'T1'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _selectedTerminal == 'T1'
                                    ? AppColors.brandNavy
                                    : AppColors.neutral500,
                              ),
                              const SizedBox(width: AppSpacing.space12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Terminal 1 (Santacruz)', style: AppTypography.labelLarge),
                                    Text(
                                      'Domestic Flights (IndiGo, SpiceJet) • Ground Arrivals Curb',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Pickup Bay Guidance (For T2)
              if (_selectedTerminal == 'T2' && isArrival) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Bay at Level P4',
                          style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBay,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(borderRadius: AppRadii.border8),
                            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Level P4 West (Bays W1-W6)',
                              child: Text('Level P4 West (Bays W1-W6)'),
                            ),
                            DropdownMenuItem(
                              value: 'Level P4 East (Bays E1-E6)',
                              child: Text('Level P4 East (Bays E1-E6)'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _selectedBay = v!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
              ],

              // Booking Mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Timing Mode',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _bookingMode == 'on_demand'
                                    ? AppColors.brandNavy.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: _bookingMode == 'on_demand'
                                      ? AppColors.brandNavy
                                      : AppColors.neutral300,
                                ),
                              ),
                              onPressed: () => setState(() => _bookingMode = 'on_demand'),
                              child: const Text('On-Demand (Now)'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _bookingMode == 'advance'
                                    ? AppColors.brandNavy.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: _bookingMode == 'advance'
                                      ? AppColors.brandNavy
                                      : AppColors.neutral300,
                                ),
                              ),
                              onPressed: () => setState(() => _bookingMode = 'advance'),
                              child: const Text('Advance (Flight Time)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),

              AppPrimaryButton(
                label: 'Set Location & Check Eligibility',
                icon: const Icon(Icons.pin_drop_rounded, size: 20),
                onPressed: () {
                  context.push(
                    '${RouteNames.locationPicker}?direction=$_direction&terminal=$_selectedTerminal&mode=$_bookingMode',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
