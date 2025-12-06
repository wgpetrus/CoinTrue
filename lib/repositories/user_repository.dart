import '../models/user.dart';

/// Abstract interface for user data persistence operations
/// 
/// This interface defines the contract for user data management,
/// including creating, retrieving, updating, and checking existence
/// of user records. Implementations should handle data persistence
/// to the appropriate backend (e.g., Firestore, local database).
/// 
/// All methods should handle errors appropriately and throw
/// app-specific exceptions when operations fail.
abstract class UserRepository {
  /// Creates a new user record in the data store
  /// 
  /// Saves the provided [user] object to the backend. This is typically
  /// called when a new user signs up or completes their first login.
  /// 
  /// Returns the created [User] object, potentially with updated fields
  /// from the backend (e.g., server-generated timestamps).
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [ValidationException] if user data is invalid
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 1.5, 8.2
  Future<User> createUser(User user);

  /// Retrieves a user by their unique identifier
  /// 
  /// Fetches the user record associated with the given [userId] from
  /// the backend. Returns null if no user with that ID exists.
  /// 
  /// Returns the [User] object if found, or null if not found.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 8.2, 8.4
  Future<User?> getUser(String userId);

  /// Updates an existing user record
  /// 
  /// Updates the user record in the backend with the data from the
  /// provided [user] object. The user is identified by their ID field.
  /// 
  /// This method is typically used when a user completes their profile
  /// or updates their information.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [ValidationException] if user data is invalid
  /// - [AuthException.userNotFound] if the user doesn't exist
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 8.3, 8.5
  Future<void> updateUser(User user);

  /// Checks if a user exists in the data store
  /// 
  /// Verifies whether a user record with the given [userId] exists
  /// in the backend. This is useful for determining if a user is
  /// new or existing during authentication flows.
  /// 
  /// Returns true if the user exists, false otherwise.
  /// 
  /// Throws:
  /// - [NetworkException] if there are connectivity issues
  /// - [UnexpectedException] for unexpected errors
  /// 
  /// Validates: Requirements 1.5, 8.1
  Future<bool> userExists(String userId);
}
