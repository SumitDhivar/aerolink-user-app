import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage wrapping FlutterSecureStorage.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'aerolink_access_token';
  static const String _keyUserId = 'aerolink_user_id';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyUserId);
  }
}
