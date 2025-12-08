import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'core/config/firebase_options.dart';
import 'controllers/controllers.dart';
import 'controllers/crypto/crypto_controllers.dart';
import 'services/services.dart';
import 'services/crypto/crypto_services.dart';
import 'repositories/repositories.dart';
import 'repositories/crypto/crypto_repositories.dart';
import 'views/screens/screens.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'utils/https_validator.dart';
import 'utils/error_handler.dart';
import 'models/models.dart';

void main() async {
  // Initialize comprehensive error logging
  _initializeErrorLogging();
  
  try {
    _logInitializationStep('Starting app initialization');
    
    WidgetsFlutterBinding.ensureInitialized();
    _logInitializationStep('Flutter binding initialized');
    
    // Log system information for debugging
    _logSystemDiagnostics();
    
    // Configurar validação HTTPS para todas as requisições
    // Requisito: 6.2 - Uso exclusivo de HTTPS
    try {
      HttpsValidator.configureHttpClient();
      _logInitializationStep('HTTPS validation configured');
    } catch (e, stackTrace) {
      _logInitializationError('HTTPS configuration failed', e, stackTrace);
      // Continue without HTTPS validation - not critical for app startup
    }
    
    // Inicializar formatação de datas para pt_BR
    try {
      await initializeDateFormatting('pt_BR', null);
      _logInitializationStep('Date formatting initialized for pt_BR');
    } catch (e, stackTrace) {
      _logInitializationError('Date formatting initialization failed', e, stackTrace);
      // Continue without localized date formatting - not critical
    }
    
    // Initialize Firebase with comprehensive error handling
    bool firebaseInitialized = false;
    try {
      _logInitializationStep('Starting Firebase initialization');
      
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        firebaseInitialized = true;
        _logInitializationStep('Firebase initialized successfully');
      } else {
        // Firebase already initialized (hot reload scenario)
        firebaseInitialized = true;
        _logInitializationStep('Firebase already initialized - reusing existing instance');
      }
    } catch (e, stackTrace) {
      // Check if Firebase is actually available despite the error
      if (Firebase.apps.isNotEmpty) {
        // Firebase is available, just had initialization error (duplicate-app)
        firebaseInitialized = true;
        _logInitializationStep('Firebase available despite initialization error');
      } else {
        firebaseInitialized = false;
        _logFirebaseInitializationError(e, stackTrace);
      }
      // Continue app startup
    }
    
    // Inicializar PreferencesService antes de iniciar o app
    PreferencesService? preferencesService;
    try {
      _logInitializationStep('Starting SharedPreferences initialization');
      preferencesService = await SharedPreferencesService.getInstance();
      _logInitializationStep('SharedPreferences initialized successfully');
    } catch (e, stackTrace) {
      _logInitializationError('SharedPreferences initialization failed', e, stackTrace);
      // This is critical - app cannot function without preferences
      _showCriticalErrorDialog('Failed to initialize app preferences. Please restart the app.');
      return;
    }
    
    _logInitializationStep('All initialization steps completed successfully');
    
    runApp(MyApp(
      preferencesService: preferencesService,
      firebaseInitialized: firebaseInitialized,
    ));
    
  } catch (e, stackTrace) {
    _logCriticalError('Critical error during app initialization', e, stackTrace);
    _showCriticalErrorDialog('Failed to start the app. Please restart and try again.');
  }
}

/// Aplicação principal
/// 
/// Configura o Provider para injeção de dependências e define
/// o tema global da aplicação seguindo as cores do aplicativo CoinTrue.
class MyApp extends StatelessWidget {
  final PreferencesService preferencesService;
  final bool firebaseInitialized;
  
  const MyApp({
    super.key, 
    required this.preferencesService,
    required this.firebaseInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (interfaces implementadas)
        Provider<AuthService>(
          create: (_) => firebaseInitialized 
            ? FirebaseAuthService()
            : _OfflineAuthService(),
        ),
        Provider<BiometricService>(
          create: (_) => LocalAuthService(),
        ),
        Provider<UserRepository>(
          create: (_) => firebaseInitialized 
            ? FirebaseUserRepository()
            : _OfflineUserRepository(),
        ),
        // Preferences service (já inicializado)
        Provider<PreferencesService>.value(
          value: preferencesService,
        ),
        
        // Auth Controller
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            context.read<AuthService>(),
            context.read<BiometricService>(),
            context.read<UserRepository>(),
            context.read<PreferencesService>(),
          ),
        ),
        
        // Crypto Repositories (CoinGecko - estável e confiável!)
        Provider<CryptoRepository>(
          create: (_) => CryptoRepositoryImpl(CoinGeckoApiService()),
        ),
        Provider<WalletRepository>(
          create: (_) => WalletRepositoryImpl(),
        ),
        
        // Crypto Controllers
        ChangeNotifierProvider<CryptoController>(
          create: (context) => CryptoController(
            context.read<CryptoRepository>(),
          ),
        ),
        ChangeNotifierProvider<WalletController>(
          create: (context) => WalletController(
            context.read<WalletRepository>(),
          ),
        ),
        ChangeNotifierProvider<TransactionController>(
          create: (context) => TransactionController(
            context.read<WalletRepository>(),
          ),
        ),
        ChangeNotifierProvider<PortfolioController>(
          create: (context) => PortfolioController(
            context.read<WalletRepository>(),
            context.read<CryptoRepository>(),
          ),
        ),
        
        // Notification Service and Controller
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        Provider<FCMService>(
          create: (_) => FCMService(),
        ),
        Provider<NotificationPreferencesRepository>(
          create: (_) => NotificationPreferencesRepository(),
        ),
        ChangeNotifierProvider<NotificationController>(
          create: (context) => NotificationController(
            context.read<NotificationService>(),
            context.read<NotificationPreferencesRepository>(),
            context.read<FCMService>(),
          ),
        ),
        
        // Favorites Repository and Controller
        Provider<FavoritesRepository>(
          create: (_) => FavoritesRepository(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider<FavoritesController>(
          create: (context) => FavoritesController(
            context.read<FavoritesRepository>(),
          ),
        ),
        
        // Theme Controller
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'CoinTrue',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.themeMode,
            initialRoute: '/',
            routes: _buildRoutes(),
            builder: (context, child) {
              // Wrapper para desfoque automático de inputs ao clicar fora
              return GestureDetector(
                onTap: () {
                  // Remove o foco de qualquer campo de texto ao clicar fora
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  /// Constrói as rotas da aplicação
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/biometric-setup': (context) => const BiometricSetupScreen(),
      '/home': (context) => const HomeScreen(), // HomeScreen agora é o MainScreen
      '/onboarding': (context) => const _PlaceholderScreen(title: 'Onboarding'),
    };
  }

  /// Constrói o tema global da aplicação
  ThemeData _buildTheme() {
    final colors = AppColors.light; // Tema base sempre light

    return ThemeData(
      // Cores primárias
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.white,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.info,
        surface: colors.white,
        error: colors.error,
      ),
      
      // Tipografia - seguindo o design system
      textTheme: TextTheme(
        // Títulos de página
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.darkGray,
          height: 1.3,
        ),
        // Valores monetários grandes
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: colors.darkGray,
        ),
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colors.darkGray,
        ),
        // Valores monetários médios
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.darkGray,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.darkGray,
        ),
        // Texto de corpo
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colors.darkGray,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colors.darkGray,
          height: 1.5,
        ),
        // Labels e legendas
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: colors.mediumGray,
        ),
        // Subtítulos
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colors.mediumGray,
          height: 1.4,
        ),
      ),
      
      // Tema de botões primários
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.veryLightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.veryLightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: colors.mediumGray,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: colors.darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: colors.mediumGray.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      
      // Tema de cards
      cardTheme: CardThemeData(
        color: colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colors.veryLightGray,
            width: 1,
          ),
        ),
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colors.white,
        foregroundColor: colors.darkGray,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.darkGray,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colors.veryLightGray,
        thickness: 1,
        space: 24,
      ),
    );
  }
}

/// Widget placeholder para rotas futuras
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tela $title',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Em desenvolvimento',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offline fallback AuthService when Firebase is not available
class _OfflineAuthService implements AuthService {
  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    _logOfflineOperation('signInWithEmailPassword', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<User> signUpWithEmailPassword(String email, String password, String displayName) async {
    _logOfflineOperation('signUpWithEmailPassword', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<User> signInWithGoogle() async {
    _logOfflineOperation('signInWithGoogle', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<User> signInWithApple() async {
    _logOfflineOperation('signInWithApple', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<void> signOut() async {
    _logOfflineOperation('signOut', 'Firebase not available - using offline mode');
    // No-op in offline mode
  }

  @override
  Future<User?> getCurrentUser() async {
    _logOfflineOperation('getCurrentUser', 'Firebase not available - using offline mode');
    return null;
  }

  @override
  Stream<User?> authStateChanges() {
    _logOfflineOperation('authStateChanges', 'Firebase not available - using offline mode');
    return Stream.value(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    _logOfflineOperation('sendPasswordResetEmail', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<void> deleteAccount() async {
    _logOfflineOperation('deleteAccount', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    _logOfflineOperation('updateEmail', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    _logOfflineOperation('updatePassword', 'Firebase not available - using offline mode');
    throw Exception('Firebase authentication not available. Please check your connection.');
  }

  @override
  Future<bool> isAuthenticated() async {
    _logOfflineOperation('isAuthenticated', 'Firebase not available - using offline mode');
    return false;
  }
}

/// Offline fallback UserRepository when Firebase is not available
class _OfflineUserRepository implements UserRepository {
  @override
  Future<User?> getUser(String userId) async {
    _logOfflineOperation('getUser', 'Firebase not available - using offline mode');
    return null;
  }

  @override
  Future<User> createUser(User user) async {
    _logOfflineOperation('createUser', 'Firebase not available - using offline mode');
    throw Exception('Firebase database not available. Please check your connection.');
  }

  @override
  Future<void> updateUser(User user) async {
    _logOfflineOperation('updateUser', 'Firebase not available - using offline mode');
    throw Exception('Firebase database not available. Please check your connection.');
  }

  @override
  Future<bool> userExists(String userId) async {
    _logOfflineOperation('userExists', 'Firebase not available - using offline mode');
    return false;
  }
}

// ============================================================================
// COMPREHENSIVE ERROR LOGGING AND DIAGNOSTICS
// ============================================================================

/// Initializes comprehensive error logging for the application
void _initializeErrorLogging() {
  // Set up global error handling for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    _logFlutterError(details);
  };
  
  // Set up global error handling for async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    _logAsyncError(error, stack);
    return true;
  };
  
  _logInitializationStep('Error logging initialized');
}

/// Logs system diagnostics for debugging purposes
void _logSystemDiagnostics() {
  final diagnostics = <String, dynamic>{
    'platform': Platform.operatingSystem,
    'version': Platform.operatingSystemVersion,
    'locale': Platform.localeName,
    'numberOfProcessors': Platform.numberOfProcessors,
    'isDebugMode': kDebugMode,
    'isProfileMode': kProfileMode,
    'isReleaseMode': kReleaseMode,
    'dartVersion': Platform.version,
  };
  
  developer.log(
    'System Diagnostics: $diagnostics',
    name: 'AppInitialization',
    level: 800, // INFO
  );
  
  if (kDebugMode) {
    debugPrint('🔍 System Diagnostics:');
    diagnostics.forEach((key, value) {
      debugPrint('   $key: $value');
    });
  }
}

/// Logs initialization steps with detailed information
void _logInitializationStep(String step) {
  final timestamp = DateTime.now().toIso8601String();
  
  developer.log(
    '[$timestamp] $step',
    name: 'AppInitialization',
    level: 800, // INFO
  );
  
  if (kDebugMode) {
    debugPrint('✅ [$timestamp] $step');
  }
}

/// Logs initialization errors with actionable information
void _logInitializationError(String context, dynamic error, StackTrace? stackTrace) {
  final errorInfo = _buildErrorDiagnostics(context, error, stackTrace);
  
  developer.log(
    'Initialization Error: $errorInfo',
    name: 'AppInitialization',
    level: 1000, // SEVERE
    error: error,
    stackTrace: stackTrace,
  );
  
  if (kDebugMode) {
    debugPrint('❌ Initialization Error in $context:');
    debugPrint('   Error: $error');
    if (stackTrace != null) {
      debugPrint('   Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
    }
    debugPrint('   Suggested action: Check the specific component configuration');
  }
}

/// Logs Firebase initialization errors with specific diagnostics
void _logFirebaseInitializationError(dynamic error, StackTrace? stackTrace) {
  final firebaseDiagnostics = <String, dynamic>{
    'error': error.toString(),
    'errorType': error.runtimeType.toString(),
    'platform': Platform.operatingSystem,
    'hasInternetConnection': 'unknown', // Could be enhanced with connectivity check
    'firebaseConfigExists': DefaultFirebaseOptions.currentPlatform != null,
  };
  
  developer.log(
    'Firebase initialization failed: $firebaseDiagnostics',
    name: 'FirebaseInit',
    level: 1000, // SEVERE
    error: error,
    stackTrace: stackTrace,
  );
  
  if (kDebugMode) {
    debugPrint('🔥 Firebase Initialization Failed:');
    debugPrint('   Error: $error');
    debugPrint('   Error Type: ${error.runtimeType}');
    debugPrint('   Platform: ${Platform.operatingSystem}');
    debugPrint('   Config exists: ${DefaultFirebaseOptions.currentPlatform != null}');
    debugPrint('   Action: App will continue in offline mode with limited functionality');
    if (stackTrace != null) {
      debugPrint('   Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
    }
  }
}

/// Logs Flutter framework errors
void _logFlutterError(FlutterErrorDetails details) {
  final errorInfo = <String, dynamic>{
    'library': details.library ?? 'Unknown',
    'context': details.context?.toString() ?? 'No context',
    'exception': details.exception.toString(),
    'stack': details.stack?.toString().split('\n').take(10).join('\n') ?? 'No stack trace',
  };
  
  developer.log(
    'Flutter Error: $errorInfo',
    name: 'FlutterError',
    level: 1000, // SEVERE
    error: details.exception,
    stackTrace: details.stack,
  );
  
  if (kDebugMode) {
    debugPrint('🐛 Flutter Framework Error:');
    debugPrint('   Library: ${details.library ?? "Unknown"}');
    debugPrint('   Context: ${details.context?.toString() ?? "No context"}');
    debugPrint('   Exception: ${details.exception}');
    debugPrint('   Action: Check the widget tree and state management');
  }
}

/// Logs async errors that occur outside the Flutter framework
void _logAsyncError(Object error, StackTrace stack) {
  final errorInfo = <String, dynamic>{
    'error': error.toString(),
    'errorType': error.runtimeType.toString(),
    'stack': stack.toString().split('\n').take(10).join('\n'),
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  developer.log(
    'Async Error: $errorInfo',
    name: 'AsyncError',
    level: 1000, // SEVERE
    error: error,
    stackTrace: stack,
  );
  
  if (kDebugMode) {
    debugPrint('⚡ Async Error:');
    debugPrint('   Error: $error');
    debugPrint('   Type: ${error.runtimeType}');
    debugPrint('   Action: Check async operations and error handling');
  }
}

/// Logs offline operations for debugging
void _logOfflineOperation(String operation, String message) {
  developer.log(
    'Offline Operation [$operation]: $message',
    name: 'OfflineMode',
    level: 900, // WARNING
  );
  
  if (kDebugMode) {
    debugPrint('📴 Offline Operation [$operation]: $message');
  }
}

/// Logs critical errors that prevent app startup
void _logCriticalError(String context, dynamic error, StackTrace? stackTrace) {
  final criticalInfo = _buildErrorDiagnostics(context, error, stackTrace);
  
  developer.log(
    'CRITICAL ERROR: $criticalInfo',
    name: 'CriticalError',
    level: 1200, // SHOUT
    error: error,
    stackTrace: stackTrace,
  );
  
  if (kDebugMode) {
    debugPrint('🚨 CRITICAL ERROR in $context:');
    debugPrint('   Error: $error');
    debugPrint('   Type: ${error.runtimeType}');
    debugPrint('   Action: App cannot continue - restart required');
    if (stackTrace != null) {
      debugPrint('   Stack trace: ${stackTrace.toString().split('\n').take(10).join('\n')}');
    }
  }
}

/// Builds comprehensive error diagnostics
Map<String, dynamic> _buildErrorDiagnostics(String context, dynamic error, StackTrace? stackTrace) {
  return {
    'context': context,
    'error': error.toString(),
    'errorType': error.runtimeType.toString(),
    'timestamp': DateTime.now().toIso8601String(),
    'platform': Platform.operatingSystem,
    'isDebugMode': kDebugMode,
    'hasStackTrace': stackTrace != null,
    'stackPreview': stackTrace?.toString().split('\n').take(3).join(' | ') ?? 'No stack trace',
  };
}

/// Shows critical error dialog when app cannot continue
void _showCriticalErrorDialog(String message) {
  if (kDebugMode) {
    debugPrint('🚨 CRITICAL ERROR DIALOG: $message');
    debugPrint('   In a production app, this would show a user-friendly error dialog');
    debugPrint('   For now, the error is logged and the app will attempt to continue');
  }
  
  // In a real implementation, you might want to show a dialog or navigate to an error screen
  // For now, we'll just log the critical error
  developer.log(
    'Critical error dialog would be shown: $message',
    name: 'CriticalError',
    level: 1200, // SHOUT
  );
}
