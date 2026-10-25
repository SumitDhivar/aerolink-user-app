import '../../../core/network/api_client.dart';
import '../domain/auth_tokens.dart';
import '../domain/user_profile.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<TokenResponse> login(String username, String password) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    return TokenResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenResponse> register({
    required String phone,
    required String displayName,
    required String password,
    String? email,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'phone': phone,
        'display_name': displayName,
        'password': password,
        'email': email,
        'role': 'passenger',
      },
    );
    return TokenResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfile> getMe() async {
    final response = await _apiClient.dio.get('/me');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile({
    String? displayName,
    String? preferredLanguage,
    Map<String, bool>? notificationPreferences,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) payload['display_name'] = displayName;
    if (preferredLanguage != null) payload['preferred_language'] = preferredLanguage;
    if (notificationPreferences != null) payload['notification_preferences'] = notificationPreferences;

    final response = await _apiClient.dio.patch(
      '/me',
      data: payload,
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.dio.post('/auth/logout');
  }
}
