import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aerolink_app/app/app.dart';
import 'package:aerolink_app/bootstrap/dependency_injection.dart';
import 'package:aerolink_app/core/storage/preference_service.dart';

void main() {
  testWidgets('AeroLinkApp launches successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();
    final prefService = PreferenceService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferenceServiceProvider.overrideWithValue(prefService),
        ],
        child: const AeroLinkApp(),
      ),
    );

    // Initial pump loads splash screen
    expect(find.text('AeroLink'), findsOneWidget);
    expect(find.text('CSMIA Mumbai • Ride Pooling Marketplace'), findsOneWidget);
  });
}
