import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bootstrap/dependency_injection.dart';
import '../domain/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final isAuthed = await _repository.isAuthenticated();
    if (!isAuthed) {
      state = const Unauthenticated();
      return;
    }

    final result = await _repository.getCurrentUser();
    result.when(
      success: (user) {
        state = Authenticated(user);
      },
      failure: (error) {
        state = Unauthenticated(error.message);
      },
    );
  }

  Future<bool> login(String username, String password) async {
    state = const AuthLoading();
    final result = await _repository.login(username: username, password: password);
    return result.when(
      success: (tokens) {
        state = Authenticated(tokens.user);
        return true;
      },
      failure: (error) {
        state = Unauthenticated(error.message);
        return false;
      },
    );
  }

  Future<bool> register({
    required String phone,
    required String displayName,
    required String password,
    String? email,
  }) async {
    state = const AuthLoading();
    final result = await _repository.register(
      phone: phone,
      displayName: displayName,
      password: password,
      email: email,
    );
    return result.when(
      success: (tokens) {
        state = Authenticated(tokens.user);
        return true;
      },
      failure: (error) {
        state = Unauthenticated(error.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _repository.logout();
    state = const Unauthenticated();
  }
}
