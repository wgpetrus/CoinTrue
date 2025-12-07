import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/asset_loader.dart';
import '../../../utils/error_handler.dart';
import '../../../services/initialization_service.dart';
import '../../../models/initialization_state.dart';
import '../auth/login_screen.dart';
import '../crypto/home_screen.dart';
import 'onboarding_screen.dart';
import '../auth/email_verification_screen.dart';
import '../auth/biometric_lock_screen.dart';

/// Enhanced Splash Screen with robust initialization flow
/// 
/// Features:
/// - Progressive loading with detailed status
/// - Error handling with retry mechanisms
/// - User-friendly error messages
/// - Timeout handling for initialization steps
/// - Fallback behavior for failed components
/// 
/// Requisitos: 1.1, 1.2, 1.3, 4.5
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  
  InitializationState? _initState;
  String _statusMessage = 'Initializing app...';
  bool _showError = false;
  bool _canRetry = false;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _logoController.forward();
  }

  /// Starts the initialization process with progress tracking
  Future<void> _startInitialization() async {
    final initService = InitializationService.instance;
    
    // Listen to initialization state changes
    initService.stateStream.listen(_onInitializationStateChanged);
    
    try {
      // Start initialization
      final result = await initService.initialize();
      
      if (!mounted) return;
      
      if (result.canContinue) {
        // Initialization successful or partial - continue with app flow
        await _continueWithAppFlow(result);
      } else {
        // Critical failure - show error
        _showCriticalError(result.criticalError ?? 'Unknown initialization error');
      }
      
    } catch (error, stackTrace) {
      if (!mounted) return;
      
      final errorResult = ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'splash_initialization',
      );
      
      _showCriticalError(errorResult.userMessage);
    }
  }

  /// Handles initialization state changes
  void _onInitializationStateChanged(InitializationState state) {
    if (!mounted) return;
    
    setState(() {
      _initState = state;
      _updateProgressAndStatus(state);
    });
  }

  /// Updates progress and status message based on initialization state
  void _updateProgressAndStatus(InitializationState state) {
    final summary = state.getSummary();
    
    // Calculate progress
    if (summary.totalSteps > 0) {
      _progress = (summary.successfulSteps + summary.skippedSteps) / summary.totalSteps;
      _progressController.animateTo(_progress);
    }
    
    // Update status message
    switch (state.currentStep) {
      case InitializationStep.starting:
        _statusMessage = 'Starting app...';
        break;
      case InitializationStep.flutterBinding:
        _statusMessage = 'Initializing Flutter...';
        break;
      case InitializationStep.httpsValidation:
        _statusMessage = 'Configuring security...';
        break;
      case InitializationStep.dateFormatting:
        _statusMessage = 'Setting up localization...';
        break;
      case InitializationStep.firebase:
        _statusMessage = 'Connecting to services...';
        break;
      case InitializationStep.preferences:
        _statusMessage = 'Loading preferences...';
        break;
      case InitializationStep.completed:
        _statusMessage = 'Ready!';
        break;
      case InitializationStep.failed:
        _statusMessage = 'Initialization failed';
        break;
    }
    
    // Check for errors (but ignore Firebase errors - they're not critical)
    if (state.hasCriticalFailure) {
      final criticalSteps = state.criticalFailedSteps;
      if (criticalSteps.isNotEmpty) {
        final failedStep = criticalSteps.first;
        
        // Ignore Firebase failures - app works in offline mode
        if (failedStep == InitializationStep.firebase) {
          _showError = false;
          _errorMessage = null;
          return;
        }
        
        final stepResult = state.stepResults[failedStep];
        _showError = true;
        _errorMessage = stepResult?.errorMessage ?? 'Critical initialization failure';
        _canRetry = state.canRetry;
      }
    } else if (summary.failedSteps > 0 && !summary.isMostlySuccessful) {
      // Don't show warnings visually - just continue
      _showError = false;
      _errorMessage = null;
      _canRetry = state.canRetry;
    }
  }

  /// Continues with the app flow after successful initialization
  Future<void> _continueWithAppFlow(InitializationResult result) async {
    // Wait minimum time to show splash
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    try {
      final authController = context.read<AuthController>();
      final notificationController = context.read<NotificationController>();
      
      // Check session
      await authController.checkSession();
      
      // Initialize notifications if user authenticated
      if (authController.isAuthenticated && authController.currentUser != null) {
        try {
          await notificationController.initialize(authController.currentUser!.id);
        } catch (error) {
          // Non-critical error - log but continue
          debugPrint('Failed to initialize notifications: $error');
        }
      }
      
      // Navigate based on auth state
      _navigateBasedOnAuthState(authController);
      
    } catch (error, stackTrace) {
      final errorResult = ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'app_flow_continuation',
      );
      
      _showCriticalError(errorResult.userMessage);
    }
  }

  /// Shows critical error with retry option
  void _showCriticalError(String message) {
    // Don't show Firebase errors visually - just continue to login
    // Firebase errors are not critical - app works in offline mode
    if (message.contains('Firebase') || message.contains('duplicate-app')) {
      // Continue to login screen without showing error
      _navigateToLogin();
      return;
    }
    
    setState(() {
      _showError = true;
      _errorMessage = message;
      _canRetry = _initState?.canRetry ?? false;
      _statusMessage = 'Initialization failed';
    });
  }

  /// Retries the initialization process
  Future<void> _retryInitialization() async {
    setState(() {
      _showError = false;
      _errorMessage = null;
      _canRetry = false;
      _progress = 0.0;
      _statusMessage = 'Retrying initialization...';
    });
    
    _progressController.reset();
    
    final initService = InitializationService.instance;
    
    try {
      final result = await initService.retry();
      
      if (!mounted) return;
      
      if (result.canContinue) {
        await _continueWithAppFlow(result);
      } else {
        _showCriticalError(result.criticalError ?? 'Retry failed');
      }
      
    } catch (error, stackTrace) {
      if (!mounted) return;
      
      final errorResult = ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'splash_retry',
      );
      
      _showCriticalError(errorResult.userMessage);
    }
  }

  /// Navega para a tela apropriada baseada no estado de autenticação
  void _navigateBasedOnAuthState(AuthController authController) {
    if (authController.isAuthenticated) {
      final user = authController.currentUser;
      
      if (user == null) {
        _navigateToLogin();
        return;
      }
      
      // Verifica se tem biometria configurada - SE SIM, EXIGE AUTENTICAÇÃO
      if (authController.biometricEnabled) {
        _navigateToBiometricLock();
        return;
      }
      
      // Verifica se o email foi verificado (apenas para contas de email/senha)
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      final isEmailPasswordAccount = firebaseUser?.providerData.any(
        (info) => info.providerId == 'password'
      ) ?? false;
      
      if (isEmailPasswordAccount && !(firebaseUser?.emailVerified ?? false)) {
        // Email não verificado → EmailVerificationScreen
        _navigateToEmailVerification();
        return;
      }
      
      // Verifica se precisa completar perfil
      if (!user.profileComplete) {
        _navigateToOnboarding();
      } else {
        _navigateToHome();
      }
    } else {
      // Não autenticado → LoginScreen
      _navigateToLogin();
    }
  }

  /// Navega para a tela de bloqueio biométrico
  void _navigateToBiometricLock() async {
    final authenticated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const BiometricLockScreen(),
      ),
    );
    
    // Se autenticou com sucesso, continua o fluxo
    if (authenticated == true && mounted) {
      final authController = context.read<AuthController>();
      final user = authController.currentUser;
      
      if (user == null) {
        _navigateToLogin();
        return;
      }
      
      // Verifica se o email foi verificado (apenas para contas de email/senha)
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      final isEmailPasswordAccount = firebaseUser?.providerData.any(
        (info) => info.providerId == 'password'
      ) ?? false;
      
      if (isEmailPasswordAccount && !(firebaseUser?.emailVerified ?? false)) {
        _navigateToEmailVerification();
        return;
      }
      
      // Verifica se precisa completar perfil
      if (!user.profileComplete) {
        _navigateToOnboarding();
      } else {
        _navigateToHome();
      }
    }
  }

  /// Navega para a tela de verificação de email
  void _navigateToEmailVerification() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EmailVerificationScreen(),
      ),
    );
  }

  /// Navega para a tela de onboarding
  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }

  /// Navega para a tela home
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  /// Navega para a tela de login
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    return Scaffold(
      backgroundColor: colors.white,
      body: Center(
        child: _buildLogo(colors),
      ),
    );
  }

  Widget _buildLogo(AppColors colors) {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_logoController.value * 0.2),
          child: Opacity(
            opacity: _logoController.value,
            child: AssetLoader.loadAppLogo(
              width: 160,
              height: 160,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(AppColors colors) {
    return Column(
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: colors.lightGray,
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Status message
        Text(
          _statusMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Detailed progress info (debug mode only)
        if (_initState != null && kDebugMode) ...[
          const SizedBox(height: 8),
          Text(
            '${_initState!.getSummary().successfulSteps}/${_initState!.getSummary().totalSteps} steps completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.mediumGray.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorSection(AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Error icon
          PhosphorIcon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            size: 32,
            color: colors.error,
          ),
          
          const SizedBox(height: 12),
          
          // Error title
          Text(
            'Initialization Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Error message
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              // Retry button
              if (_canRetry) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _retryInitialization,
                    icon: PhosphorIcon(
                      PhosphorIcons.arrowClockwise(),
                      size: 18,
                      color: colors.white,
                    ),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // Continue anyway button (for non-critical errors)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _continueAnyway,
                  icon: PhosphorIcon(
                    PhosphorIcons.arrowRight(),
                    size: 18,
                    color: colors.mediumGray,
                  ),
                  label: const Text('Continue'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.mediumGray,
                    side: BorderSide(color: colors.mediumGray),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.2, duration: 300.ms);
  }

  /// Attempts to continue with the app despite errors
  void _continueAnyway() async {
    // Only allow continue if there are no critical failures
    if (_initState?.hasCriticalFailure == true) {
      _showSnackBar('Cannot continue due to critical errors. Please retry.');
      return;
    }
    
    try {
      final authController = context.read<AuthController>();
      await authController.checkSession();
      _navigateBasedOnAuthState(authController);
    } catch (error) {
      _showSnackBar('Failed to continue. Please retry initialization.');
    }
  }

  /// Shows a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
