/// User profile model conforming to OpenAPI UserProfile schema.
class UserProfile {
  final String id;
  final String displayName;
  final List<String> roles;
  final String accountStatus; // active, restricted, suspended, closed
  final String verificationStatus; // not_started, pending, verified, rejected, expired, action_required

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.roles,
    required this.accountStatus,
    required this.verificationStatus,
  });

  bool get isVerified => verificationStatus == 'verified';
  bool get isRestricted => accountStatus == 'restricted' || accountStatus == 'suspended';
  bool get isPassenger => roles.contains('passenger');

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: (json['display_name'] as String?) ?? 'Passenger',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['passenger'],
      accountStatus: (json['account_status'] as String?) ?? 'active',
      verificationStatus: (json['verification_status'] as String?) ?? 'not_started',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'roles': roles,
        'account_status': accountStatus,
        'verification_status': verificationStatus,
      };

  UserProfile copyWith({
    String? displayName,
    List<String>? roles,
    String? accountStatus,
    String? verificationStatus,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      roles: roles ?? this.roles,
      accountStatus: accountStatus ?? this.accountStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
