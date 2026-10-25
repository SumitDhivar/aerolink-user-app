import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../domain/coverage_result.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  final String direction;
  final String terminal;
  final String bookingMode;

  const LocationPickerScreen({
    super.key,
    this.direction = 'airport_arrival',
    this.terminal = 'T2',
    this.bookingMode = 'on_demand',
  });

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  late LatLng _centerPoint;
  final MapController _mapController = MapController();
  bool _isChecking = false;
  final double _gpsAccuracy = 8.5; // Meters
  String _addressLabel = 'Powai, Hiranandani Gardens, Mumbai';
  bool _confirmedPin = false;

  // Preset location shortcuts for pilot testing
  final List<({String name, LatLng point})> _quickLocations = const [
    (name: 'Powai (Hiranandani)', point: LatLng(19.1176, 72.9060)),
    (name: 'Andheri East (MIDC)', point: LatLng(19.1136, 72.8697)),
    (name: 'Thane (Cadbury)', point: LatLng(19.2056, 72.9734)),
    (name: 'Bandra West (Outside Zone)', point: LatLng(19.0596, 72.8295)),
  ];

  @override
  void initState() {
    super.initState();
    _centerPoint = const LatLng(19.1176, 72.9060); // Powai default
  }

  Future<void> _checkCoverage() async {
    setState(() => _isChecking = true);

    final coverageRepo = ref.read(coverageRepositoryProvider);
    final purpose = widget.direction == 'airport_arrival' ? 'destination' : 'origin';

    final locationInput = LocationInput(
      coordinates: Coordinates(
        latitude: _centerPoint.latitude,
        longitude: _centerPoint.longitude,
        accuracyM: _gpsAccuracy,
      ),
      confirmedPin: _confirmedPin,
      placeId: _addressLabel,
    );

    final result = await coverageRepo.checkCoverage(
      location: locationInput,
      purpose: purpose,
    );

    if (!mounted) return;
    setState(() => _isChecking = false);

    result.when(
      success: (response) {
        if (response.isEligible) {
          // Zone is eligible! Proceed to Flight Search or Journey Review
          context.push(
            '${RouteNames.flightSearch}?'
            'direction=${widget.direction}&'
            'terminal=${widget.terminal}&'
            'mode=${widget.bookingMode}&'
            'lat=${_centerPoint.latitude}&'
            'lng=${_centerPoint.longitude}&'
            'label=$_addressLabel',
          );
        } else if (response.isUncertain) {
          _showUncertainDialog(locationInput);
        } else {
          _showOutsideZoneSheet(locationInput, response.resultCode);
        }
      },
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  void _showUncertainDialog(LocationInput loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.border16),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: AppSpacing.space8),
            Text('GPS Near Boundary'),
          ],
        ),
        content: const Text(
          'Your location is close to an operational corridor boundary. Please confirm your exact drop-off pin or drag the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Adjust Map'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _confirmedPin = true);
              _checkCoverage();
            },
            child: const Text('Confirm Pin Here'),
          ),
        ],
      ),
    );
  }

  void _showOutsideZoneSheet(LocationInput loc, String resultCode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetTop24),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadii.borderFull,
                ),
                child: const Icon(Icons.location_off_rounded, color: AppColors.error, size: 30),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Area Outside Active Pilot',
                style: AppTypography.titleMedium.copyWith(color: AppColors.neutral900),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'AeroLink is currently operating controlled corridors for CSMIA Mumbai. This address is not yet part of an active zone ($resultCode).',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral700),
              ),
              const SizedBox(height: AppSpacing.space24),
              AppPrimaryButton(
                label: 'Request Coverage in this Area',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push(
                    '${RouteNames.expansionRequest}?'
                    'lat=${loc.coordinates.latitude}&'
                    'lng=${loc.coordinates.longitude}&'
                    'direction=${widget.direction}&'
                    'label=$_addressLabel',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Choose Another Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArrival = widget.direction == 'airport_arrival';

    return Scaffold(
      backgroundColor: AppColors.softNeutral,
      appBar: AppBar(
        title: Text(isArrival ? 'Select Destination' : 'Select City Pickup'),
      ),
      body: Stack(
        children: [
          // OpenStreetMap Vector / Raster Tile View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerPoint,
              initialZoom: 13.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  _centerPoint = camera.center;
                  _confirmedPin = false;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aerolink.app',
              ),
            ],
          ),

          // Center Pin Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandNavy,
                      borderRadius: AppRadii.border8,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      isArrival ? 'Destination Pin' : 'Pickup Pin',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.surfaceWhite),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.location_pin,
                    color: AppColors.error,
                    size: 44,
                  ),
                ],
              ),
            ),
          ),

          // Top Info Bar (GPS Precision & Preset Selector)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.95),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed_rounded, color: AppColors.success, size: 18),
                          const SizedBox(width: AppSpacing.space8),
                          Expanded(
                            child: Text(
                              'GPS Precision: ±${_gpsAccuracy.toStringAsFixed(0)}m (High Accuracy)',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.neutral800),
                            ),
                          ),
                          AppStatusBadge(
                            label: _confirmedPin ? 'Confirmed' : 'Unconfirmed',
                            variant: _confirmedPin ? BadgeVariant.success : BadgeVariant.neutral,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // Quick presets scrollable row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickLocations.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.space8),
                          child: ActionChip(
                            label: Text(item.name),
                            onPressed: () {
                              setState(() {
                                _centerPoint = item.point;
                                _addressLabel = item.name;
                                _confirmedPin = false;
                              });
                              _mapController.move(item.point, 14.0);
                            },
                            backgroundColor: AppColors.surfaceWhite,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderFull),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadii.sheetTop24,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.brandNavy, size: 24),
                        const SizedBox(width: AppSpacing.space8),
                        Expanded(
                          child: Text(
                            _addressLabel,
                            style: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'Lat: ${_centerPoint.latitude.toStringAsFixed(4)}, Lng: ${_centerPoint.longitude.toStringAsFixed(4)}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppPrimaryButton(
                      label: 'Verify Area Coverage & Proceed',
                      isLoading: _isChecking,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      onPressed: _checkCoverage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
