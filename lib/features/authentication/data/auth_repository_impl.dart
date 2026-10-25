import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_tokens.dart';
import '../domain/user_profile.dart';
import 'auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Future<ApiResult<TokenResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final tokenResponse = await apiService.login(username, password);
      await secureStorage.saveToken(tokenResponse.accessToken);
      await secureStorage.saveUserId(tokenResponse.user.id);
      return Success(tokenResponse);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/auth/login'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<TokenResponse>> register({
    required String phone,
    required String displayName,
    required String password,
    String? email,
  }) async {
    try {
      final tokenResponse = await apiService.register(
        phone: phone,
        displayName: displayName,
        password: password,
        email: email,
      );
      await secureStorage.saveToken(tokenResponse.accessToken);
      await secureStorage.saveUserId(tokenResponse.user.id);
      return Success(tokenResponse);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/auth/register'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<UserProfile>> getCurrentUser() async {
    try {
      final user = await apiService.getMe();
      return Success(user);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/me'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<UserProfile>> updateProfile({
    String? displayName,
    String? preferredLanguage,
    Map<String, bool>? notificationPreferences,
  }) async {
    try {
      final user = await apiService.updateProfile(
        displayName: displayName,
        preferredLanguage: preferredLanguage,
        notificationPreferences: notificationPreferences,
      );
      return Success(user);
    } on DioException catch (e) {
      return Failure(apiClient.mapDioException(e));
    } catch (e) {
      return Failure(apiClient.mapDioException(
        DioException(requestOptions: RequestOptions(path: '/me'), error: e),
      ));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await apiService.logout();
    } catch (_) {
      // Best-effort remote revocation
    } finally {
      await secureStorage.clearAuthData();
    }
    return const Success(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
