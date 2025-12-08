/// Enum representing types of biometric authentication available
enum BiometricType {
  /// Fingerprint authentication
  fingerprint,

  /// Face recognition (Face ID on iOS, Face Unlock on Android)
  face,

  /// Iris scanning
  iris,
}

/// Abstract interface for biometric authentication services
/// 
/// This interface defines the contract for biometric authentication operations
/// including availability checking, authentication, and secure credential storage.
/// Implementations must handle platform-specific biometric APIs and error cases.
abstract class BiometricService {
  /// Checks if biometric authentication is available on the device
  /// 
  /// Returns true if the device has biometric hardware and at least one
  /// biometric is enrolled, false otherwise.
  /// 
  /// This method should be called before attempting to use biometric
  /// authentication to ensure the device supports it.
  /// 
  /// Returns true if biometric authentication is available.
  /// 
  /// Validates: Requirements 2.1
  Future<bool> isAvailable();

  /// Gets the list of available biometric types on the device
  /// 
  /// Returns a list of [BiometricType] values representing the types
  /// of biometric authentication available (e.g., fingerprint, face, iris).
  /// 
  /// Returns an empty list if no biometric authentication is available.
  /// 
  /// Returns a [List<BiometricType>] of available biometric types.
  /// 
  /// Validates: Requirements 2.1
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Authenticates the user using biometric authentication
  /// 
  /// Prompts the user to authenticate using their enrolled biometric
  /// (fingerprint, face, etc.). The [reason] parameter is displayed to
  /// the user explaining why authentication is required.
  /// 
  /// The [useErrorDialogs] parameter controls whether the system should
  /// show error dialogs for authentication failures.
  /// 
  /// Returns true if authentication succeeds, false otherwise.
  /// 
  /// Throws:
  /// - [BiometricException.notAvailable] if biometric is not available
  /// - [BiometricException.notEnrolled] if no biometric is enrolled
  /// - [BiometricException.authFailed] if authentication fails
  /// - [BiometricException.tooManyAttempts] if too many failed attempts
  /// - [BiometricException.cancelled] if user cancels
  /// 
  /// Validates: Requirements 2.2, 2.5
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
  });

  /// Saves user credentials securely for biometric authentication
  /// 
  /// Stores the [userId] in secure storage, encrypted and protected by
  /// the device's secure enclave/keystore. This allows the user to be
  /// identified after successful biometric authentication.
  /// 
  /// The credentials are stored using platform-specific secure storage:
  /// - iOS: Keychain with biometric protection
  /// - Android: KeyStore with biometric protection
  /// 
  /// Throws:
  /// - [BiometricException] if storage fails
  /// 
  /// Validates: Requirements 2.3, 6.1
  Future<void> saveCredentials(String userId);

  /// Retrieves the stored user ID from secure storage
  /// 
  /// Returns the user ID that was previously stored using [saveCredentials],
  /// or null if no credentials are stored.
  /// 
  /// This method should only be called after successful biometric
  /// authentication to retrieve the user's identity.
  /// 
  /// Returns the stored user ID, or null if not found.
  /// 
  /// Validates: Requirements 2.4, 2.5
  Future<String?> getStoredUserId();

  /// Deletes stored credentials from secure storage
  /// 
  /// Removes all biometric-related credentials from secure storage.
  /// This should be called when the user disables biometric authentication
  /// or signs out.
  /// 
  /// After calling this method, [getStoredUserId] will return null.
  /// 
  /// Validates: Requirements 10.3
  Future<void> deleteCredentials();
}
