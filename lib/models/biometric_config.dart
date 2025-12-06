import 'package:equatable/equatable.dart';

/// Configuration model for biometric authentication
class BiometricConfig extends Equatable {
  /// Whether biometric authentication is enabled
  final bool enabled;

  /// User ID associated with the biometric credentials
  final String? userId;

  /// Timestamp of when biometric was last used
  final DateTime? lastUsed;

  const BiometricConfig({
    required this.enabled,
    this.userId,
    this.lastUsed,
  });

  /// Creates a disabled biometric config
  const BiometricConfig.disabled()
      : enabled = false,
        userId = null,
        lastUsed = null;

  /// Creates an enabled biometric config
  BiometricConfig.enabled({
    required String userId,
    DateTime? lastUsed,
  })  : enabled = true,
        userId = userId,
        lastUsed = lastUsed ?? DateTime.now();

  /// Converts BiometricConfig to JSON map
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'userId': userId,
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  /// Creates BiometricConfig from JSON map
  factory BiometricConfig.fromJson(Map<String, dynamic> json) {
    return BiometricConfig(
      enabled: json['enabled'] as bool,
      userId: json['userId'] as String?,
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  /// Creates a copy of this BiometricConfig with updated fields
  BiometricConfig copyWith({
    bool? enabled,
    String? userId,
    DateTime? lastUsed,
  }) {
    return BiometricConfig(
      enabled: enabled ?? this.enabled,
      userId: userId ?? this.userId,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  List<Object?> get props => [enabled, userId, lastUsed];

  @override
  String toString() {
    return 'BiometricConfig(enabled: $enabled, userId: $userId, lastUsed: $lastUsed)';
  }
}
