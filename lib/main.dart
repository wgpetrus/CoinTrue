import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/crypto/crypto_controllers.dart';
import 'controllers/notification_controller.dart';
import 'services/services.dart';
import 'services/crypto/crypto_services.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'repositories/repositories.dart';
import 'repositories/crypto/crypto_repositories.dart';
import 'repositories/notification_preferences_repository.dart';
import 'views/screens/screens.dart';
import 'utils/constants.dart';
import 'utils/https_validator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar validação HTTPS para todas as requisições
  // Requisito: 6.2 - Uso exclusivo de HTTPS
  HttpsValidator.configureHttpClient();
  
  // Inicializar formatação de datas para pt_BR
  await initializeDateFormatting('pt_BR', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar PreferencesService antes de iniciar o app
  final preferencesService = await SharedPreferencesService.getInstance();
  
  runApp(MyApp(preferencesService: preferencesService));
}

/// Aplicação principal
/// 
/// Configura o Provider para injeção de dependências e define
/// o tema global da aplicação seguindo as cores do aplicativo CoinTrue.
class MyApp extends StatelessWidget {
  final PreferencesService preferencesService;
  
  const MyApp({super.key, required this.preferencesService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (interfaces implementadas)
        Provider<AuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<BiometricService>(
          create: (_) => LocalAuthService(),
        ),
        Provider<UserRepository>(
          create: (_) => FirebaseUserRepository(),
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
      ],
      child: MaterialApp(
        title: 'CoinTrue',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
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
    final colors = AppConstants.colors;

    return ThemeData(
      // Cores primárias
      primaryColor: colors.yellow,
      scaffoldBackgroundColor: colors.white,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: colors.yellow,
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
          backgroundColor: colors.yellow,
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
          borderSide: BorderSide(color: colors.yellowDark, width: 2),
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
              color: AppConstants.colors.darkGray.withValues(alpha: 0.5),
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
                color: AppConstants.colors.darkGray.withValues(alpha: 0.7),
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
