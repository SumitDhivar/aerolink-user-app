import 'package:shared_preferences/shared_preferences.dart';

/// Local preferences storage using SharedPreferences.
class PreferenceService {
  final SharedPreferences _prefs;

  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyPreferredLanguage = 'preferred_language';
  static const String _keySelectedTerminal = 'selected_terminal';

  PreferenceService(this._prefs);

  static Future<PreferenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceService(prefs);
  }

  bool get isOnboardingSeen => _prefs.getBool(_keyOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen(bool seen) async {
    await _prefs.setBool(_keyOnboardingSeen, seen);
  }

  String get preferredLanguage => _prefs.getString(_keyPreferredLanguage) ?? 'en';

  Future<void> setPreferredLanguage(String lang) async {
    await _prefs.setString(_keyPreferredLanguage, lang);
  }

  String get selectedTerminal => _prefs.getString(_keySelectedTerminal) ?? 'T2';

  Future<void> setSelectedTerminal(String terminal) async {
    await _prefs.setString(_keySelectedTerminal, terminal);
  }
}
