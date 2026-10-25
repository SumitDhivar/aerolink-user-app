import '../domain/user_profile.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserProfile user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated([this.message]);
}
