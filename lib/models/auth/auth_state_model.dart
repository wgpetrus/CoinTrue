import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Enum representing the authentication state
enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Authentication state model
class AuthState extends Equatable {
  /// Current authentication status
  final AuthStatus status;

  /// Currently authenticated user (null if not authenticated)
  final User? user;

  /// Error message if status is error
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  /// Initial unauthenticated state
  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null;

  /// Authenticated state with user
  const AuthState.authenticated(User user)
      : status = AuthStatus.authenticated,
        user = user,
        errorMessage = null;

  /// Loading state
  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  /// Error state with message
  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message;

  /// Creates a copy of this AuthState with updated fields
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, errorMessage: $errorMessage)';
  }
}
