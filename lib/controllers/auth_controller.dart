import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/exceptions.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/preferences_service.dart';
import '../repositories/user_repository.dart';
import '../utils/error_handler.dart';
import '../utils/rate_limiter.dart';
import '../utils/platform_helper.dart';

/// Controller for managing authentication state and operations
/// 
/// This controller follows the MVC pattern and uses ChangeNotifier for
/// state management. It coordinates authentication flows, manages user
/// sessions, and handles biometric authentication.
/// 
/// The controller implements dependency injection (DIP) by depending on
/// abstract interfaces rather than concrete implementations.
/// 
/// Validates: Requirements 1.1, 1.2, 1.5, 2.1-2.5, 3.1-3.5, 6.4, 7.1-7.3, 8.1-8.5
class AuthController extends ChangeNotifier {
  final AuthService _authService;
  final BiometricService _biometricService;
  final UserRepository _userRepository;
  final PreferencesService _preferencesService;
  RateLimiter? _rateLimiter;

  // Private state
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _biometricEnabled = false;

  /// Constructor with dependency injection (DIP principle)
  AuthController(
    this._authService,
    this._biometricService,
    this._userRepository,
    this._preferencesService, {
    RateLimiter? rateLimiter,
  }) : _rateLimiter = rateLimiter {
    // Se não foi fornecido um rate limiter, inicializar um
    if (_rateLimiter == null) {
      _initializeRateLimiter();
    }
  }

  /// Inicializa o rate limiter de forma assíncrona
  Future<void> _initializeRateLimiter() async {
    try {
      _rateLimiter = await RateLimiter.create(
        maxAttempts: 5,
        resetWindow: const Duration(minutes: 5),
        blockDuration: const Duration(minutes: 15),
      );
    } catch (e) {
      // Silenciosamente falha em testes ou quando SharedPreferences não está disponível
      // O controller continuará funcionando sem rate limiting
      if (kDebugMode) {
        debugPrint('Info: Rate limiter not available (normal in tests)');
      }
    }
  }

  // Public getters
  
  /// Currently authenticated user, or null if not authenticated
  User? get currentUser => _currentUser;

  /// Whether an authentication operation is in progress
  bool get isLoading => _isLoading;

  /// Whether a user is currently authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Current error message, or null if no error
  String? get error => _error;

  /// Whether biometric authentication is enabled
  bool get biometricEnabled => _biometricEnabled;

  /// Access to biometric service (for UI)
  BiometricService get biometricService => _biometricService;

  /// Access to auth service (for UI)
  AuthService get authService => _authService;

  /// Whether the current platform supports biometric authentication
  /// 
  /// Returns false for web and desktop platforms.
  /// Validates: Requirements 9.3, 9.4
  bool get platformSupportsBiometric => PlatformHelper.supportsBiometric;

  // Public methods

  /// Signs in a user using Google OAuth
  /// 
  /// Initiates the Google OAuth flow, handles loading states, and manages
  /// errors appropriately. Implements delay progressive on failures.
  /// 
  /// Validates: Requirements 1.1, 1.3, 1.5, 7.1, 7.2, 7.3
  Future<void> signInWithGoogle() async {
    await _performLogin(() => _authService.signInWithGoogle());
  }

  /// Signs in a user using Apple OAuth
  /// 
  /// Initiates the Apple OAuth flow, handles loading states, and manages
  /// errors appropriately. Implements delay progressive on failures.
  /// 
  /// Validates: Requirements 1.2, 1.3, 1.5, 7.1, 7.2, 7.3
  Future<void> signInWithApple() async {
    await _performLogin(() => _authService.signInWithApple());
  }

  /// Signs in a user using email and password
  /// 
  /// Authenticates with email/password, handles loading states, and manages
  /// errors appropriately. Implements delay progressive on failures.
  /// 
  /// Validates: Requirements 1.3, 1.5, 7.1, 7.2, 7.3
  Future<void> signInWithEmailPassword(String email, String password) async {
    await _performLogin(() => _authService.signInWithEmailPassword(email, password));
  }

  /// Creates a new user account with email and password
  /// 
  /// Registers a new user, handles loading states, and manages errors.
  /// 
  /// Validates: Requirements 1.3, 1.5, 8.1, 8.2
  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    await _performLogin(() => _authService.signUpWithEmailPassword(
      email,
      password,
      displayName,
    ));
  }

  /// Sends a password reset email
  /// 
  /// Sends an email with password reset link.
  /// 
  /// Validates: Requirements 6.5
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError(e, context: 'sendPasswordResetEmail');
    }
  }

  /// Signs in a user using biometric authentication
  /// 
  /// Verifies biometric availability, authenticates the user, and retrieves
  /// stored credentials to complete the login.
  /// 
  /// Validates: Requirements 2.1, 2.4, 2.5, 9.3, 9.4
  Future<void> signInWithBiometric() async {
    // Check if platform supports biometric
    if (!PlatformHelper.supportsBiometric) {
      _setError(PlatformHelper.getUnsupportedFeatureMessage('biometric'));
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Check if biometric is available
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        throw const BiometricException.notAvailable();
      }

      // Authenticate with biometric
      final authenticated = await _biometricService.authenticate(
        reason: 'Autentique-se para acessar sua conta',
      );

      if (!authenticated) {
        throw const BiometricException.authFailed();
      }

      // Get stored user ID
      final userId = await _biometricService.getStoredUserId();
      if (userId == null) {
        throw const BiometricException(
          'Credenciais não encontradas. Configure a biometria novamente.',
          code: 'NO_CREDENTIALS',
        );
      }

      // Get current user from auth service
      final user = await _authService.getCurrentUser();
      if (user == null || user.id != userId) {
        throw const AuthException(
          'Sessão expirada. Faça login novamente.',
          code: 'SESSION_EXPIRED',
        );
      }

      _currentUser = user;
      _biometricEnabled = true;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError(e, context: 'signInWithBiometric');
    }
  }

  /// Enables biometric authentication for the current user
  /// 
  /// Checks device support, requests permission, authenticates the user,
  /// and stores credentials securely. Saves preference immediately.
  /// 
  /// Validates: Requirements 2.1, 2.2, 2.3, 9.3, 9.4, 10.1, 10.4
  Future<void> enableBiometric() async {
    // Check if platform supports biometric
    if (!PlatformHelper.supportsBiometric) {
      _setError(PlatformHelper.getUnsupportedFeatureMessage('biometric'));
      return;
    }

    if (_currentUser == null) {
      _setError('Você precisa estar autenticado para ativar a biometria.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Check if biometric is available
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        throw const BiometricException.notAvailable();
      }

      // Request permission and authenticate
      final authenticated = await _biometricService.authenticate(
        reason: 'Autentique-se para ativar o login biométrico',
      );

      if (!authenticated) {
        throw const BiometricException.authFailed();
      }

      // Save credentials securely
      await _biometricService.saveCredentials(_currentUser!.id);

      // Save preference (Requirement 10.1)
      await _preferencesService.saveBiometricEnabled(true);
      await _preferencesService.saveUserId(_currentUser!.id);

      _biometricEnabled = true;
      _setLoading(false);
      notifyListeners(); // Apply changes immediately (Requirement 10.4)
    } catch (e) {
      _handleError(e, context: 'enableBiometric');
    }
  }

  /// Disables biometric authentication
  /// 
  /// Removes stored credentials, clears preferences, and updates the biometric enabled state.
  /// Changes are applied immediately.
  /// 
  /// Validates: Requirements 10.3, 10.4
  Future<void> disableBiometric() async {
    _setLoading(true);
    _clearError();

    try {
      await _biometricService.deleteCredentials();
      
      // Clear preferences (Requirement 10.3)
      await _preferencesService.saveBiometricEnabled(false);
      await _preferencesService.removeUserId();
      
      _biometricEnabled = false;
      _setLoading(false);
      notifyListeners(); // Apply changes immediately (Requirement 10.4)
    } catch (e) {
      _handleError(e, context: 'disableBiometric');
    }
  }

  /// Signs out the current user
  /// 
  /// Invalidates the session, clears all authentication data, removes
  /// biometric credentials, and clears preferences.
  /// 
  /// Validates: Requirements 3.5, 6.3, 10.3
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      await _biometricService.deleteCredentials();
      
      // Clear preferences (Requirement 10.3)
      await _preferencesService.saveBiometricEnabled(false);
      await _preferencesService.removeUserId();
      
      // Reset rate limiter
      if (_rateLimiter != null) {
        await _rateLimiter!.reset();
      }
      
      _currentUser = null;
      _biometricEnabled = false;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError(e, context: 'signOut');
    }
  }

  /// Deletes the current user account permanently
  /// 
  /// This action is irreversible and will delete all user data and preferences.
  Future<void> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      await _biometricService.deleteCredentials();
      
      // Clear all preferences
      await _preferencesService.clear();
      
      // Reset rate limiter
      if (_rateLimiter != null) {
        await _rateLimiter!.reset();
      }
      
      _currentUser = null;
      _biometricEnabled = false;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError(e, context: 'deleteAccount');
    }
  }

  /// Updates the user's email address
  /// 
  /// Requires the current password for re-authentication.
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateEmail(newEmail, currentPassword);
      
      // Reload user data
      _currentUser = await _authService.getCurrentUser();
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError(e, context: 'updateEmail');
    }
  }

  /// Updates the user's password
  /// 
  /// Requires the current password for re-authentication.
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🟡 AuthController: Updating password...');
      await _authService.updatePassword(currentPassword, newPassword);
      debugPrint('🟡 AuthController: Password updated successfully');
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('🟡 AuthController: Error updating password: $e');
      _handleError(e, context: 'updatePassword');
      _setLoading(false);
      rethrow; // Relança o erro para que a UI possa tratá-lo
    }
  }

  /// Checks if there's a valid session when the app starts
  /// 
  /// Verifies if a user is already authenticated and restores the session.
  /// Also loads biometric preference from storage.
  /// 
  /// Validates: Requirements 3.2, 3.3, 10.1
  Future<void> checkSession() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        _currentUser = user;
        
        // Load biometric preference from storage (Requirement 10.1)
        final biometricEnabled = await _preferencesService.isBiometricEnabled();
        final storedUserId = await _preferencesService.getUserId();
        
        // Verify that stored user ID matches current user
        _biometricEnabled = biometricEnabled && storedUserId == user.id;
        
        // If preference is enabled but credentials are missing, disable it
        if (_biometricEnabled) {
          final hasCredentials = await _biometricService.getStoredUserId();
          if (hasCredentials == null) {
            _biometricEnabled = false;
            await _preferencesService.saveBiometricEnabled(false);
          }
        }
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError(e, context: 'checkSession');
    }
  }

  // Private helper methods

  /// Performs a login operation with common error handling and loading states
  /// 
  /// Implements rate limiting to prevent brute force attacks.
  /// Validates: Requirements 6.4
  Future<void> _performLogin(Future<User> Function() loginFunction) async {
    // Verificar se está bloqueado por rate limiting
    if (_rateLimiter != null) {
      final isBlocked = await _rateLimiter!.isBlocked();
      if (isBlocked) {
        final remainingTime = await _rateLimiter!.getRemainingBlockTime();
        if (remainingTime != null) {
          throw RateLimitExceededException(
            'Muitas tentativas de login',
            remainingTime,
          );
        }
      }
    }

    _setLoading(true);
    _clearError();

    try {
      final user = await loginFunction();
      
      // Check if user is new and handle accordingly
      await _handleNewUser(user);
      
      _currentUser = user;
      _error = null; // Limpa qualquer erro anterior
      
      // Registrar sucesso no rate limiter
      if (_rateLimiter != null) {
        await _rateLimiter!.recordSuccessfulAttempt();
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      // Registrar falha no rate limiter e aplicar delay
      if (_rateLimiter != null && e is! RateLimitExceededException) {
        try {
          final delay = await _rateLimiter!.recordFailedAttempt();
          debugPrint('Rate limiter: Applying delay of ${delay.inSeconds}s');
          await Future.delayed(delay);
        } catch (rateLimitError) {
          debugPrint('Warning: Rate limiter error: $rateLimitError');
          // Continua mesmo se o rate limiter falhar
        }
      }
      
      _handleError(e, context: 'performLogin');
    }
  }

  /// Handles new user detection and creates user record if needed
  /// 
  /// Validates: Requirements 1.5, 8.1, 8.2, 8.3
  Future<void> _handleNewUser(User user) async {
    try {
      if (user.isNewUser) {
        // Check if user already exists in repository
        final exists = await _userRepository.userExists(user.id);
        
        if (!exists) {
          // Create new user record
          await _userRepository.createUser(user);
        }
      }
    } catch (e) {
      // Se falhar ao criar o usuário no Firestore, apenas loga o erro
      // mas não impede o login (usuário já está autenticado no Firebase Auth)
      debugPrint('Warning: Failed to create user record in Firestore: $e');
      // Não propaga o erro para não bloquear o login
    }
  }



  /// Sets loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  /// Sets error message and notifies listeners
  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Clears error message
  void _clearError() {
    _error = null;
  }

  /// Public method to clear error (for UI)
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Handles errors and converts them to user-friendly messages
  /// 
  /// Uses ErrorHandler utility for centralized error handling with
  /// proper logging and severity classification.
  /// 
  /// Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5
  void _handleError(dynamic error, {String? context}) {
    // Use ErrorHandler to process the error
    final errorResult = ErrorHandler.handleError(
      error,
      stackTrace: StackTrace.current,
      context: context ?? 'AuthController',
    );

    // Set the user-friendly message
    _setError(errorResult.userMessage);
  }
}
