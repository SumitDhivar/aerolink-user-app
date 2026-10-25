import '../../../core/network/api_result.dart';
import 'auth_tokens.dart';
import 'user_profile.dart';

abstract class AuthRepository {
  Future<ApiResult<TokenResponse>> login({
    required String username,
    required String password,
  });

  Future<ApiResult<TokenResponse>> register({
    required String phone,
    required String displayName,
    required String password,
    String? email,
  });

  Future<ApiResult<UserProfile>> getCurrentUser();

  Future<ApiResult<UserProfile>> updateProfile({
    String? displayName,
    String? preferredLanguage,
    Map<String, bool>? notificationPreferences,
  });

  Future<ApiResult<void>> logout();

  Future<bool> isAuthenticated();
}
