import 'package:flutter_test/flutter_test.dart';
import 'package:aerolink_app/features/authentication/domain/auth_tokens.dart';
import 'package:aerolink_app/features/authentication/domain/user_profile.dart';
import 'package:aerolink_app/features/booking/domain/booking_models.dart';
import 'package:aerolink_app/features/booking/domain/fare_quote_models.dart';
import 'package:aerolink_app/features/coverage/domain/coverage_result.dart';
import 'package:aerolink_app/features/flight/domain/flight_status.dart';
import 'package:aerolink_app/features/payments/domain/payment_models.dart';
import 'package:aerolink_app/features/safety/domain/incident_models.dart';
import 'package:aerolink_app/features/trips/domain/trip_models.dart';

void main() {
  group('Identity & UserProfile Models', () {
    test('UserProfile deserializes accurately from OpenAPI schema', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'display_name': 'Sumit Dhivar',
        'roles': ['passenger'],
        'account_status': 'active',
        'verification_status': 'verified',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(profile.displayName, 'Sumit Dhivar');
      expect(profile.isVerified, isTrue);
      expect(profile.isPassenger, isTrue);
      expect(profile.isRestricted, isFalse);
    });

    test('TokenResponse deserializes correctly with embedded user', () {
      final json = {
        'access_token': 'jwt-test-token-value',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': {
          'id': 'u1',
          'display_name': 'Test Rider',
          'roles': ['passenger'],
          'account_status': 'active',
          'verification_status': 'not_started',
        },
      };

      final tokenResponse = TokenResponse.fromJson(json);

      expect(tokenResponse.accessToken, 'jwt-test-token-value');
      expect(tokenResponse.tokenType, 'bearer');
      expect(tokenResponse.user.displayName, 'Test Rider');
      expect(tokenResponse.user.isVerified, isFalse);
    });
  });

  group('Coverage & Location Models', () {
    test('Coordinates & LocationInput serialization/deserialization', () {
      final loc = LocationInput(
        coordinates: const Coordinates(latitude: 19.0886, longitude: 72.8680, accuracyM: 8.0),
        confirmedPin: true,
        placeId: 'CSMIA T2',
      );

      final json = loc.toJson();
      final roundTrip = LocationInput.fromJson(json);

      expect(roundTrip.coordinates.latitude, 19.0886);
      expect(roundTrip.coordinates.longitude, 72.8680);
      expect(roundTrip.confirmedPin, isTrue);
      expect(roundTrip.placeId, 'CSMIA T2');
    });

    test('CoverageCheckResponse parsing for eligible and outside zones', () {
      final eligibleJson = {
        'eligible': true,
        'result_code': 'ELIGIBLE',
        'zone_id': 'zone-powai-1',
        'zone_version': 1,
        'next_action': 'none',
        'checked_at': '2026-10-25T12:00:00Z',
      };

      final eligibleResponse = CoverageCheckResponse.fromJson(eligibleJson);
      expect(eligibleResponse.isEligible, isTrue);
      expect(eligibleResponse.resultCode, 'ELIGIBLE');

      final outsideJson = {
        'eligible': false,
        'result_code': 'OUTSIDE_ACTIVE_ZONE',
        'next_action': 'submit_expansion_request',
        'checked_at': '2026-10-25T12:00:00Z',
      };

      final outsideResponse = CoverageCheckResponse.fromJson(outsideJson);
      expect(outsideResponse.isOutside, isTrue);
      expect(outsideResponse.nextAction, 'submit_expansion_request');
    });
  });

  group('Flight Context Models', () {
    test('FlightStatus parses Aviationstack payload properly', () {
      final json = {
        'flight_number': '6E204',
        'flight_date': '2026-10-25',
        'status': 'landed',
        'estimated_arrival': '2026-10-25T14:30:00Z',
        'terminal': 'T2',
        'gate': 'Gate 45B',
        'freshness': 'live',
        'source': 'aviationstack',
      };

      final flight = FlightStatus.fromJson(json);

      expect(flight.flightNumber, '6E204');
      expect(flight.status, 'landed');
      expect(flight.terminal, 'T2');
      expect(flight.isAvailable, isTrue);
      expect(flight.isStale, isFalse);
    });
  });

  group('Fare Quote & Booking Models', () {
    test('FareQuote parses components and segment-wise distance splitting', () {
      final json = {
        'quote_id': 'q1',
        'currency': 'INR',
        'total': 480.0,
        'status': 'estimate',
        'policy_version': 'v1.0-pilot',
        'expires_at': '2026-10-25T23:59:59Z',
        'components': [
          {'code': 'base_fare', 'description': 'Airport Base Access', 'amount': 150.0},
          {'code': 'solo_distance', 'description': 'Solo Direct Segment', 'amount': 180.0},
          {'code': 'shared_segment', 'description': 'Shared Distance Split', 'amount': 110.0},
          {'code': 'toll', 'description': 'Airport Toll & Parking', 'amount': 40.0},
        ],
        'segment_allocations': [
          {
            'segment_id': 'seg-1',
            'distance_km': 8.5,
            'passenger_count_on_segment': 2,
            'passenger_amount': 110.0,
          }
        ],
      };

      final quote = FareQuote.fromJson(json);

      expect(quote.total, 480.0);
      expect(quote.components.length, 4);
      expect(quote.segmentAllocations.length, 1);
      expect(quote.segmentAllocations.first.passengerCountOnSegment, 2);
    });

    test('Booking model state helpers evaluate accurately', () {
      final json = {
        'id': 'bk-12345',
        'status': 'confirmed',
        'direction': 'airport_arrival',
        'requested_time': '2026-10-25T14:00:00Z',
        'origin': {
          'coordinates': {'latitude': 19.0886, 'longitude': 72.8680},
          'confirmed_pin': true,
          'place_id': 'CSMIA T2',
        },
        'destination': {
          'coordinates': {'latitude': 19.1176, 'longitude': 72.9060},
          'confirmed_pin': true,
          'place_id': 'Powai',
        },
        'fare_quote_id': 'q1',
        'created_at': '2026-10-25T13:50:00Z',
      };

      final booking = Booking.fromJson(json);

      expect(booking.id, 'bk-12345');
      expect(booking.isConfirmed, isTrue);
      expect(booking.isCancelled, isFalse);
    });
  });

  group('Trips & Stops Models', () {
    test('Trip & TripStop parsing with ordered sequences', () {
      final json = {
        'id': 'tr-9988',
        'status': 'in_progress',
        'direction': 'airport_arrival',
        'stops': [
          {
            'stop_id': 's1',
            'sequence': 1,
            'type': 'pickup',
            'label': 'CSMIA T2 Level P4 Bay W2',
            'status': 'completed',
            'estimated_time': '2026-10-25T14:15:00Z',
          },
          {
            'stop_id': 's2',
            'sequence': 2,
            'type': 'dropoff',
            'label': 'Powai Hiranandani',
            'status': 'pending',
            'estimated_time': '2026-10-25T14:45:00Z',
          },
        ],
        'driver_id': 'drv-1',
        'vehicle_id': 'veh-1',
      };

      final trip = Trip.fromJson(json);

      expect(trip.id, 'tr-9988');
      expect(trip.isActive, isTrue);
      expect(trip.stops.length, 2);
      expect(trip.stops.first.isCompleted, isTrue);
      expect(trip.stops.last.isPending, isTrue);
    });
  });

  group('Payments & Incident Models', () {
    test('Payment model flags captured/pending accurately', () {
      final json = {
        'id': 'pay-4411',
        'status': 'captured',
        'amount': 480.0,
        'currency': 'INR',
        'provider_reference': 'rzp_mock_123',
        'updated_at': '2026-10-25T14:20:00Z',
      };

      final payment = Payment.fromJson(json);

      expect(payment.isCaptured, isTrue);
      expect(payment.amount, 480.0);
      expect(payment.currency, 'INR');
    });

    test('Incident models support critical severity indicators', () {
      final req = const IncidentCreateRequest(
        category: 'safety',
        description: 'Unauthorized route detour observed',
        severity: 'critical',
      );

      final json = req.toJson();
      expect(json['category'], 'safety');
      expect(json['severity'], 'critical');

      final res = IncidentResponse.fromJson({
        'id': 'inc-77',
        'category': 'safety',
        'description': 'Unauthorized route detour observed',
        'source': 'passenger',
        'severity': 'critical',
        'status': 'safeguards_applied',
        'created_at': '2026-10-25T14:22:00Z',
      });

      expect(res.isCritical, isTrue);
      expect(res.status, 'safeguards_applied');
    });
  });
}
