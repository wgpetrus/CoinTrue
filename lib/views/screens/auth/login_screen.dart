import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../../utils/asset_loader.dart';
import '../../../utils/platform_helper.dart';
import '../../../utils/theme_helper.dart';
import '../../widgets/widgets.dart';
import 'email_password_login_screen.dart';
import 'email_verification_screen.dart';
import '../crypto/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// Tela de Login
/// 
/// Implementa a interface de login com Material Design clean e moderno.
/// Oferece opções de login social (Google e Apple) e biometria quando configurada.
/// Observa o estado do AuthController para exibir loading, erros e navegar
/// baseado no estado de autenticação.
/// 
/// Requisitos: 1.1, 1.2, 1.4, 2.4, 5.1, 5.2, 5.3, 7.1, 7.2, 7.3
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Adiciona listener para observar mudanças no estado de autenticação
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Limpa erros ao entrar na tela
      context.read<AuthController>().clearError();
      _setupAuthListener();
    });
  }

  /// Configura listener para mudanças no estado de autenticação
  void _setupAuthListener() {
    final authController = context.read<AuthController>();
    authController.addListener(_handleAuthStateChange);
  }

  @override
  void dispose() {
    // Remove listener ao descartar o widget
    final authController = context.read<AuthController>();
    authController.removeListener(_handleAuthStateChange);
    super.dispose();
  }

  /// Manipula mudanças no estado de autenticação
  void _handleAuthStateChange() {
    final authController = context.read<AuthController>();
    
    // Só redireciona se:
    // 1. Acabou de autenticar
    // 2. Ainda não navegou
    // 3. Não há erro
    // 4. Não está carregando
    if (authController.isAuthenticated && 
        mounted && 
        !_hasNavigated &&
        authController.error == null &&
        !authController.isLoading) {
      _hasNavigated = true;
      _navigateBasedOnUserState(authController);
    }
  }

  /// Navega baseado no estado do usuário
  void _navigateBasedOnUserState(AuthController authController) {
    final user = authController.currentUser;
    
    if (user == null) return;
    
    // Verifica se é conta de email/senha e se o email foi verificado
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final isEmailPasswordAccount = firebaseUser?.providerData.any(
      (info) => info.providerId == 'password'
    ) ?? false;
    
    if (isEmailPasswordAccount && !(firebaseUser?.emailVerified ?? false)) {
      // Email não verificado → EmailVerificationScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const EmailVerificationScreen(),
        ),
        (route) => false, // Remove todas as rotas anteriores
      );
      return;
    }
    
    // Se perfil não está completo, vai para onboarding
    if (!user.profileComplete) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
        (route) => false, // Remove todas as rotas anteriores
      );
    } else {
      // Perfil completo, vai para Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false, // Remove todas as rotas anteriores
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Stack(
            children: [
              _buildBody(context, authController),
              // Loading overlay apenas quando está carregando
              if (authController.isLoading)
                LoadingOverlay(
                  isLoading: true,
                  message: AppConstants.strings.processing,
                  child: const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Constrói o corpo da tela
  Widget _buildBody(BuildContext context, AuthController authController) {
    final colors = context.colors;
    
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determina se é tablet baseado na largura
          final isTablet = constraints.maxWidth > 600;
          final horizontalPadding = isTablet ? 80.0 : 24.0;
          
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo da empresa
                      _buildLogo(colors, isTablet),
                      SizedBox(height: isTablet ? 64 : 48),
                      
                      // Título e subtítulo
                      _buildHeader(colors),
                      SizedBox(height: isTablet ? 48 : 32),
                      
                      // Mensagem de erro (se houver)
                      if (authController.error != null) ...[
                        ErrorMessage(
                          message: authController.error!,
                          onRetry: () {
                            // Limpa o erro ao tentar novamente
                            // O usuário pode tentar fazer login novamente
                          },
                          showRetry: false,
                        )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .shake(hz: 4, curve: Curves.easeInOut),
                        const SizedBox(height: 24),
                      ],
                      
                      // Prompt de biometria (se configurada e plataforma suporta)
                      if (authController.biometricEnabled && 
                          PlatformHelper.supportsBiometric) ...[
                        BiometricPrompt(
                          onAuthenticate: () => _handleBiometricLogin(authController),
                          onSkip: () {
                            // Usuário escolheu pular biometria
                            // Continua na tela de login
                          },
                          isAuthenticating: authController.isLoading,
                        ),
                        const SizedBox(height: 24),
                        
                        // Divisor "ou"
                        _buildDivider(colors),
                        const SizedBox(height: 24),
                      ],
                      
                      // Botões de login social
                      _buildSocialLoginButtons(authController),
                      
                      const SizedBox(height: 24),
                      
                      // Divisor "ou"
                      _buildDivider(colors),
                      
                      const SizedBox(height: 24),
                      
                      // Login com Email/Senha
                      _buildEmailPasswordButton(colors),
                      
                      const SizedBox(height: 32),
                      
                      // Indicador de segurança
                      _buildSecurityIndicator(colors),
                      
                      const SizedBox(height: 24),
                      
                      // Termos e Política de Privacidade
                      _buildTermsAndPrivacy(colors),
                      
                      const SizedBox(height: 16),
                      
                      // Versão do app
                      _buildAppVersion(colors),
                      
                      // Espaçamento flexível para empurrar conteúdo para cima em telas grandes
                      if (isTablet) const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Constrói o logo da empresa
  Widget _buildLogo(AppColors colors, bool isTablet) {
    final size = isTablet ? 220.0 : 180.0;
    
    return Center(
      child: AssetLoader.loadAppLogo(
        width: size,
        height: size,
      )
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(0.9, 0.9),
            duration: 400.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  /// Constrói o cabeçalho com título e subtítulo
  Widget _buildHeader(AppColors colors) {
    final strings = AppConstants.strings;
    
    return Column(
      children: [
        Text(
          strings.welcomeTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
        const SizedBox(height: 8),
        Text(
          strings.welcomeSubtitle,
          style: TextStyle(
            fontSize: 16,
            color: colors.darkGray.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
      ],
    );
  }

  /// Constrói o divisor "ou"
  Widget _buildDivider(AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.darkGray.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(
              fontSize: 14,
              color: colors.darkGray.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colors.darkGray.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Constrói os botões de login social
  Widget _buildSocialLoginButtons(AuthController authController) {
    return Column(
      children: [
        // Botão Google - Disponível em todas as plataformas suportadas
        if (PlatformHelper.supportsGoogleSignIn)
          Opacity(
            opacity: authController.isLoading ? 0.5 : 1.0,
            child: SocialLoginButton(
              provider: SocialProvider.google,
              onPressed: authController.isLoading 
                  ? null 
                  : () => _handleGoogleLogin(authController),
              isLoading: false, // Não mostra loading no botão
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
        
        // Espaçamento entre botões (apenas se ambos estiverem visíveis)
        if (PlatformHelper.supportsGoogleSignIn && PlatformHelper.supportsAppleSignIn)
          const SizedBox(height: 16),
        
        // Botão Apple - Apenas em iOS, macOS e Web
        if (PlatformHelper.supportsAppleSignIn)
          SocialLoginButton(
            provider: SocialProvider.apple,
            onPressed: authController.isLoading 
                ? null 
                : () => _handleAppleLogin(authController),
            isLoading: authController.isLoading,
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
      ],
    );
  }

  /// Manipula login com Google
  Future<void> _handleGoogleLogin(AuthController authController) async {
    try {
      await authController.signInWithGoogle();
    } catch (e) {
      // Erro já é tratado pelo controller
      debugPrint('Error in Google login: $e');
    }
  }

  /// Manipula login com Apple
  Future<void> _handleAppleLogin(AuthController authController) async {
    try {
      await authController.signInWithApple();
    } catch (e) {
      // Erro já é tratado pelo controller
      debugPrint('Error in Apple login: $e');
    }
  }

  /// Manipula login com biometria
  Future<void> _handleBiometricLogin(AuthController authController) async {
    try {
      await authController.signInWithBiometric();
    } catch (e) {
      // Erro já é tratado pelo controller
      debugPrint('Error in biometric login: $e');
    }
  }

  /// Constrói o indicador de segurança
  Widget _buildSecurityIndicator(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 16,
          color: colors.success,
        ),
        const SizedBox(width: 6),
        Text(
          'Conexão segura e criptografada',
          style: TextStyle(
            fontSize: 12,
            color: colors.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Constrói os termos e política de privacidade
  Widget _buildTermsAndPrivacy(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: colors.mediumGray,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Ao continuar, você concorda com nossos '),
            TextSpan(
              text: 'Termos de Uso',
              style: TextStyle(
                color: colors.info,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              // TODO: Adicionar GestureRecognizer para abrir termos
            ),
            const TextSpan(text: ' e '),
            TextSpan(
              text: 'Política de Privacidade',
              style: TextStyle(
                color: colors.info,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              // TODO: Adicionar GestureRecognizer para abrir política
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Constrói a versão do app
  Widget _buildAppVersion(AppColors colors) {
    return Text(
      'Versão 1.0.0',
      style: TextStyle(
        fontSize: 11,
        color: colors.mediumGray.withValues(alpha: 0.6),
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Constrói o botão de login com email/senha
  Widget _buildEmailPasswordButton(AppColors colors) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmailPasswordLoginScreen(),
            ),
          );
        },
        icon: PhosphorIcon(
          PhosphorIcons.envelope(),
          size: 20,
          color: colors.darkGray,
        ),
        label: Text(
          'Continuar com Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.darkGray,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surfaceElevated,
          side: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
  }
}
