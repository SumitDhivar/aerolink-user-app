import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../coverage/domain/coverage_result.dart';
import '../domain/booking_models.dart';
import '../domain/fare_quote_models.dart';

class JourneyReviewScreen extends ConsumerStatefulWidget {
  final String direction;
  final String terminal;
  final String mode;
  final double lat;
  final double lng;
  final String label;
  final String? flight;
  final String? flightDate;

  const JourneyReviewScreen({
    super.key,
    required this.direction,
    required this.terminal,
    required this.mode,
    required this.lat,
    required this.lng,
    required this.label,
    this.flight,
    this.flightDate,
  });

  @override
  ConsumerState<JourneyReviewScreen> createState() => _JourneyReviewScreenState();
}

class _JourneyReviewScreenState extends ConsumerState<JourneyReviewScreen> {
  int _partySize = 1;
  String _luggageProfile = 'standard';
  bool _isLoadingQuote = true;
  bool _isCreatingBooking = false;
  FareQuote? _fareQuote;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchFareQuote());
  }

  LocationInput get _airportLocation {
    final lat = widget.terminal == 'T1' ? AppConfig.csmiaT1Lat : AppConfig.csmiaT2Lat;
    final lng = widget.terminal == 'T1' ? AppConfig.csmiaT1Lng : AppConfig.csmiaT2Lng;
    return LocationInput(
      coordinates: Coordinates(latitude: lat, longitude: lng, accuracyM: 5.0),
      confirmedPin: true,
      placeId: 'CSMIA ${widget.terminal}',
    );
  }

  LocationInput get _cityLocation {
    return LocationInput(
      coordinates: Coordinates(latitude: widget.lat, longitude: widget.lng, accuracyM: 10.0),
      confirmedPin: true,
      placeId: widget.label,
    );
  }

  Future<void> _fetchFareQuote() async {
    setState(() {
      _isLoadingQuote = true;
      _errorMessage = null;
    });

    final bookingRepo = ref.read(bookingRepositoryProvider);
    final isArrival = widget.direction == 'airport_arrival';

    final request = FareQuoteRequest(
      direction: widget.direction,
      origin: isArrival ? _airportLocation : _cityLocation,
      destination: isArrival ? _cityLocation : _airportLocation,
      requestedTime: DateTime.now().toUtc(),
      partySize: _partySize,
      luggageProfile: _luggageProfile,
      bookingMode: widget.mode,
    );

    final result = await bookingRepo.requestFareQuote(request);
    if (!mounted) return;

    result.when(
      success: (quote) {
        setState(() {
          _fareQuote = quote;
          _isLoadingQuote = false;
        });
      },
      failure: (err) {
        setState(() {
          _errorMessage = err.message;
          _isLoadingQuote = false;
        });
      },
    );
  }

  Future<void> _createBookingAndMatch() async {
    if (_fareQuote == null) return;

    setState(() => _isCreatingBooking = true);
    final bookingRepo = ref.read(bookingRepositoryProvider);
    final isArrival = widget.direction == 'airport_arrival';

    final createRequest = BookingCreateRequest(
      direction: widget.direction,
      origin: isArrival ? _airportLocation : _cityLocation,
      destination: isArrival ? _cityLocation : _airportLocation,
      requestedTime: DateTime.now().toUtc(),
      bookingMode: widget.mode,
      partySize: _partySize,
      luggageProfile: _luggageProfile,
      flightNumber: widget.flight,
      flightDate: widget.flightDate,
      fareQuoteId: _fareQuote!.quoteId,
    );

    final createResult = await bookingRepo.createBooking(createRequest);
    if (!mounted) return;

    createResult.when(
      success: (booking) async {
        // Automatically submit matching request
        await bookingRepo.requestMatching(booking.id);
        if (!mounted) return;
        setState(() => _isCreatingBooking = false);
        context.go(RouteNames.matchingPath(booking.id));
      },
      failure: (err) {
        setState(() => _isCreatingBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArrival = widget.direction == 'airport_arrival';

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: const Text('Journey Review & Fare'),
      ),
      body: SafeArea(
        child: _isLoadingQuote
            ? const AppLoadingView(message: 'Calculating segment-wise distance splitting quote...')
            : _errorMessage != null
                ? AppErrorView(
                    message: _errorMessage!,
                    onRetry: _fetchFareQuote,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Itinerary Route Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.trip_origin_rounded, color: AppColors.brandNavy, size: 20),
                                    const SizedBox(width: AppSpacing.space8),
                                    Expanded(
                                      child: Text(
                                        isArrival ? 'CSMIA ${widget.terminal} (Pickup)' : widget.label,
                                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 9),
                                  height: 24,
                                  width: 2,
                                  color: AppColors.neutral300,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: AppColors.brandTeal, size: 20),
                                    const SizedBox(width: AppSpacing.space8),
                                    Expanded(
                                      child: Text(
                                        isArrival ? widget.label : 'CSMIA ${widget.terminal} (Drop-off)',
                                        style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space16),

                        // Party Size & Luggage Selectors
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.space16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Passengers (Party Size)', style: AppTypography.labelLarge),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: _partySize > 1
                                              ? () {
                                                  setState(() => _partySize--);
                                                  _fetchFareQuote();
                                                }
                                              : null,
                                        ),
                                        Text('$_partySize', style: AppTypography.titleMedium),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: _partySize < 8
                                              ? () {
                                                  setState(() => _partySize++);
                                                  _fetchFareQuote();
                                                }
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.neutral200),
                                const SizedBox(height: AppSpacing.space8),
                                Text('Luggage Profile', style: AppTypography.labelLarge),
                                const SizedBox(height: AppSpacing.space8),
                                Row(
                                  children: [
                                    _buildLuggageChip('Light', 'light'),
                                    const SizedBox(width: AppSpacing.space8),
                                    _buildLuggageChip('Standard', 'standard'),
                                    const SizedBox(width: AppSpacing.space8),
                                    _buildLuggageChip('Heavy', 'heavy'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space16),

                        // Fare Breakdown Card
                        if (_fareQuote != null) ...[
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
                                        'Estimated Fare',
                                        style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
                                      ),
                                      Text(
                                        '₹${_fareQuote!.total.toStringAsFixed(0)}',
                                        style: AppTypography.displayLarge.copyWith(
                                          color: AppColors.brandNavy,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.space4),
                                  Text(
                                    'Policy Version: ${_fareQuote!.policyVersion}',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500),
                                  ),
                                  const SizedBox(height: AppSpacing.space16),
                                  const Divider(color: AppColors.neutral200),
                                  const SizedBox(height: AppSpacing.space12),

                                  // Components
                                  ..._fareQuote!.components.map((c) => Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              c.description,
                                              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral700),
                                            ),
                                            Text(
                                              '₹${c.amount.toStringAsFixed(2)}',
                                              style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                                            ),
                                          ],
                                        ),
                                      )),

                                  // Segment Allocations
                                  if (_fareQuote!.segmentAllocations.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.space12),
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.space12),
                                      decoration: const BoxDecoration(
                                        color: AppColors.infoContainer,
                                        borderRadius: AppRadii.border8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.alt_route_rounded, size: 18, color: AppColors.info),
                                              SizedBox(width: AppSpacing.space6),
                                              Text(
                                                'Segment-Wise Distance Splitting',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.info,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSpacing.space6),
                                          Text(
                                            'Costs are split exclusively across active riders on shared road links. You are never billed for segments after you exit.',
                                            style: AppTypography.bodySmall.copyWith(color: AppColors.neutral800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space24),

                          AppPrimaryButton(
                            label: 'Confirm & Request Pooling',
                            isLoading: _isCreatingBooking,
                            icon: const Icon(Icons.check_circle_rounded, size: 20),
                            onPressed: _createBookingAndMatch,
                          ),
                          const SizedBox(height: AppSpacing.space24),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildLuggageChip(String label, String value) {
    final selected = _luggageProfile == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) {
          setState(() => _luggageProfile = value);
          _fetchFareQuote();
        }
      },
      selectedColor: AppColors.brandNavy,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected ? AppColors.surfaceWhite : AppColors.neutral700,
      ),
    );
  }
}
