import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/auth_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../crypto/home_screen.dart';
import 'onboarding_screen.dart';
import '../auth/email_verification_screen.dart';
import '../auth/biometric_lock_screen.dart';

/// Tela inicial do aplicativo (Splash Screen)
/// 
/// Exibe o logo da empresa enquanto verifica se existe uma sessão ativa.
/// Navega automaticamente para a tela apropriada baseada no estado de autenticação:
/// - Se autenticado e perfil completo → HomeScreen (futura)
/// - Se autenticado e perfil incompleto → OnboardingScreen (futura)
/// - Se não autenticado → LoginScreen
/// 
/// Requisitos: 3.2, 3.3, 3.4, 8.4, 8.5
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Verifica se existe uma sessão ativa e navega para a tela apropriada
  Future<void> _checkSession() async {
    final authController = context.read<AuthController>();
    final notificationController = context.read<NotificationController>();
    
    // Chama checkSession() do controller
    await authController.checkSession();
    
    // Inicializa notificações se usuário autenticado
    if (authController.isAuthenticated && authController.currentUser != null) {
      await notificationController.initialize(authController.currentUser!.id);
    }
    
    // Aguarda um mínimo de tempo para exibir o splash
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Navega baseado no estado de autenticação
    _navigateBasedOnAuthState(authController);
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
        child: Image.asset(
          AppAssets.logoApp,
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            // Fallback caso a imagem não carregue
            return Icon(
              Icons.account_balance_wallet,
              size: 150,
              color: colors.yellowDark,
            );
          },
        )
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
