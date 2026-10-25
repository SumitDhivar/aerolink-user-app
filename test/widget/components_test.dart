import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerolink_app/core/widgets/app_empty_view.dart';
import 'package:aerolink_app/core/widgets/app_error_view.dart';
import 'package:aerolink_app/core/widgets/app_loading_view.dart';
import 'package:aerolink_app/core/widgets/app_primary_button.dart';
import 'package:aerolink_app/core/widgets/app_secondary_button.dart';
import 'package:aerolink_app/core/widgets/app_status_badge.dart';
import 'package:aerolink_app/core/widgets/app_text_field.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppPrimaryButton Widget Tests', () {
    testWidgets('Renders label and triggers callback on tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapWidget(
        AppPrimaryButton(
          label: 'Continue',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppPrimaryButton(
          label: 'Continue',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('Is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppPrimaryButton(
          label: 'Disabled Action',
          onPressed: null,
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });
  });

  group('AppSecondaryButton Widget Tests', () {
    testWidgets('Renders outlined variant cleanly', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppSecondaryButton(
          label: 'Secondary Action',
          isOutlined: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);
    });
  });

  group('AppTextField Widget Tests', () {
    testWidgets('Renders label and updates text on user input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(wrapWidget(
        AppTextField(
          label: 'Mobile Phone',
          hint: 'Enter 10-digit number',
          controller: controller,
        ),
      ));

      expect(find.text('Mobile Phone'), findsOneWidget);
      expect(find.text('Enter 10-digit number'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '9876543210');
      expect(controller.text, '9876543210');
    });
  });

  group('AppStatusBadge Widget Tests', () {
    testWidgets('Renders uppercase label with corresponding semantic icon', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppStatusBadge(
          label: 'Verified',
          variant: BadgeVariant.success,
        ),
      ));

      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('Feedback Views Widget Tests', () {
    testWidgets('AppLoadingView displays message caption', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppLoadingView(message: 'Calculating quote...'),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Calculating quote...'), findsOneWidget);
    });

    testWidgets('AppErrorView renders message and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(wrapWidget(
        AppErrorView(
          message: 'Unable to connect to server',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Unable to connect to server'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('AppEmptyView renders title and subtext', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppEmptyView(
          title: 'No Trips Found',
          message: 'Your completed journeys will be listed here.',
        ),
      ));

      expect(find.text('No Trips Found'), findsOneWidget);
      expect(find.text('Your completed journeys will be listed here.'), findsOneWidget);
    });
  });
}
