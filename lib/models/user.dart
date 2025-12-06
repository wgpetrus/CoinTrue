import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Enum representing authentication providers
enum AuthProvider {
  google,
  apple,
}

/// User entity representing an authenticated user in the system
class User extends Equatable {
  /// Unique identifier from Firebase
  final String id;

  /// User's email address
  final String email;

  /// User's display name (optional)
  final String? displayName;

  /// URL to user's profile photo (optional)
  final String? photoUrl;

  /// Authentication provider used (google or apple)
  final AuthProvider provider;

  /// Timestamp when the account was created
  final DateTime createdAt;

  /// Flag indicating if this is the user's first login
  final bool isNewUser;

  /// Flag indicating if the user has completed their profile
  final bool profileComplete;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    required this.isNewUser,
    this.profileComplete = false,
  });

  /// Creates a User from a Firebase User object
  factory User.fromFirebase(
    firebase_auth.User firebaseUser, {
    required AuthProvider provider,
    required bool isNewUser,
    bool profileComplete = false,
  }) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      provider: provider,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      isNewUser: isNewUser,
      profileComplete: profileComplete,
    );
  }

  /// Converts User to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider.name,
      'createdAt': createdAt.toIso8601String(),
      'isNewUser': isNewUser,
      'profileComplete': profileComplete,
    };
  }

  /// Creates User from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: AuthProvider.values.firstWhere(
        (e) => e.name == json['provider'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isNewUser: json['isNewUser'] as bool,
      profileComplete: json['profileComplete'] as bool? ?? false,
    );
  }

  /// Creates a copy of this User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider? provider,
    DateTime? createdAt,
    bool? isNewUser,
    bool? profileComplete,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      isNewUser: isNewUser ?? this.isNewUser,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        provider,
        createdAt,
        isNewUser,
        profileComplete,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, '
        'provider: ${provider.name}, isNewUser: $isNewUser, '
        'profileComplete: $profileComplete)';
  }
}
