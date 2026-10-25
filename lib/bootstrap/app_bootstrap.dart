import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app.dart';
import '../core/storage/preference_service.dart';
import 'dependency_injection.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<Widget> createRootWidget() async {
    WidgetsFlutterBinding.ensureInitialized();

    final preferenceService = await PreferenceService.init();

    return ProviderScope(
      overrides: [
        preferenceServiceProvider.overrideWithValue(preferenceService),
      ],
      child: const AeroLinkApp(),
    );
  }
}
