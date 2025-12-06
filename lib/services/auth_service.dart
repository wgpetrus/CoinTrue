import '../models/user.dart';

/// Abstract interface for authentication services
/// 
/// This interface defines the contract for authentication operations
/// including social login (Google, Apple), session management, and
/// user state monitoring. Implementations must handle all authentication
/// flows and error cases appropriately.
abstract class AuthService {
  /// Signs in a user using Google OAuth
  /// 
  /// Initiates the Google OAuth flow and authenticates the user.
  /// Creates or retrieves the user profile from Firebase Auth.
  /// 
  /// Returns a [User] object on successful authentication.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException] if authentication fails
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 1.1
  Future<User> signInWithGoogle();

  /// Signs in a user using Apple OAuth
  /// 
  /// Initiates the Apple OAuth flow and authenticates the user.
  /// Creates or retrieves the user profile from Firebase Auth.
  /// 
  /// Returns a [User] object on successful authentication.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException] if authentication fails
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 1.2
  Future<User> signInWithApple();

  /// Signs in a user using email and password
  /// 
  /// Authenticates the user with email and password credentials.
  /// 
  /// Returns a [User] object on successful authentication.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException] if authentication fails
  /// - [ValidationException] if email/password format is invalid
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 1.3, 1.5, 7.1, 7.2, 7.3
  Future<User> signInWithEmailPassword(String email, String password);

  /// Creates a new user account with email and password
  /// 
  /// Registers a new user with email, password, and display name.
  /// 
  /// Returns a [User] object on successful registration.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException] if registration fails (e.g., email already in use)
  /// - [ValidationException] if email/password format is invalid
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 1.3, 1.5, 8.1, 8.2
  Future<User> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  );

  /// Sends a password reset email to the user
  /// 
  /// Sends an email with a link to reset the password.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException] if email is not found
  /// - [ValidationException] if email format is invalid
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 6.5
  Future<void> sendPasswordResetEmail(String email);

  /// Retrieves the currently authenticated user
  /// 
  /// Returns the current [User] if authenticated, or null if no user
  /// is currently signed in.
  /// 
  /// This method checks the current authentication state without
  /// triggering any authentication flows.
  /// 
  /// Returns null if no user is authenticated.
  /// 
  /// Validates: Requirements 3.2, 3.3
  Future<User?> getCurrentUser();

  /// Signs out the current user
  /// 
  /// Invalidates the current session token and clears all authentication
  /// data. This includes clearing Firebase Auth session and any locally
  /// stored authentication state.
  /// 
  /// After calling this method, [getCurrentUser] will return null and
  /// [isAuthenticated] will return false.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 3.5
  Future<void> signOut();

  /// Deletes the current user account
  /// 
  /// Permanently deletes the user's account from Firebase Auth.
  /// This action is irreversible.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException] if user needs to re-authenticate
  /// - [UnexpectedException] for unexpected errors
  Future<void> deleteAccount();

  /// Updates the user's email address
  /// 
  /// Requires recent authentication. If the user's last sign-in was too long ago,
  /// this will throw [AuthException.requiresRecentLogin].
  /// 
  /// Parameters:
  /// - [newEmail]: The new email address
  /// - [currentPassword]: The user's current password for re-authentication
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException.requiresRecentLogin] if re-authentication is needed
  /// - [AuthException.emailAlreadyInUse] if email is already registered
  /// - [AuthException.invalidEmail] if email format is invalid
  /// - [UnexpectedException] for unexpected errors
  Future<void> updateEmail(String newEmail, String currentPassword);

  /// Updates the user's password
  /// 
  /// Requires recent authentication. If the user's last sign-in was too long ago,
  /// this will throw [AuthException.requiresRecentLogin].
  /// 
  /// Parameters:
  /// - [currentPassword]: The user's current password for re-authentication
  /// - [newPassword]: The new password
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [AuthException.requiresRecentLogin] if re-authentication is needed
  /// - [AuthException.weakPassword] if new password is too weak
  /// - [AuthException.invalidCredentials] if current password is wrong
  /// - [UnexpectedException] for unexpected errors
  Future<void> updatePassword(String currentPassword, String newPassword);

  /// Provides a stream of authentication state changes
  /// 
  /// Emits a [User] object when a user signs in, and null when
  /// a user signs out. This stream allows reactive updates to
  /// authentication state throughout the application.
  /// 
  /// The stream continues to emit events as long as there are
  /// active listeners.
  /// 
  /// Returns a [Stream<User?>] that emits authentication state changes.
  /// 
  /// Validates: Requirements 3.2, 3.3
  Stream<User?> authStateChanges();

  /// Checks if a user is currently authenticated
  /// 
  /// Returns true if there is a valid authenticated user session,
  /// false otherwise. This is a convenience method that checks
  /// the current authentication state synchronously.
  /// 
  /// Returns true if authenticated, false otherwise.
  /// 
  /// Validates: Requirements 3.1, 3.2
  Future<bool> isAuthenticated();
}
