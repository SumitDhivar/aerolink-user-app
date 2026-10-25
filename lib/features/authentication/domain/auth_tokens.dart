import 'user_profile.dart';

/// Authentication response payload matching TokenResponse schema.
class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserProfile user;

  const TokenResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.expiresIn,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'bearer',
      expiresIn: (json['expires_in'] as int?) ?? 3600,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'user': user.toJson(),
      };
}
