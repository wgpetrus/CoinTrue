import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../../utils/asset_loader.dart';
import '../../widgets/widgets.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../crypto/home_screen.dart';

/// Tela de Login com Email/Senha
/// 
/// Permite que usuários façam login usando email e senha.
class EmailPasswordLoginScreen extends StatefulWidget {
  const EmailPasswordLoginScreen({super.key});

  @override
  State<EmailPasswordLoginScreen> createState() => _EmailPasswordLoginScreenState();
}

class _EmailPasswordLoginScreenState extends State<EmailPasswordLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Limpa erros ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthController>().clearError();
      }
    });
  }

  @override
  void dispose() {
    // Limpa o erro ao sair da tela
    final authController = context.read<AuthController>();
    if (authController.error != null) {
      authController.clearError();
    }
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(),
            size: 24,
            color: colors.darkGray,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Stack(
            children: [
              _buildBody(context, authController, colors),
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

  Widget _buildBody(
    BuildContext context,
    AuthController authController,
    AppColors colors,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: AssetLoader.loadAppLogo(
                  width: 120,
                  height: 120,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
              
              const SizedBox(height: 32),
              
              // Título
              Text(
                'Entrar com Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.darkGray,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Digite seu email e senha para continuar',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.mediumGray,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 32),
              
              // Campo Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu@email.com',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.envelope(),
                    size: 20,
                    color: colors.mediumGray,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite seu email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 16),
              
              // Campo Senha
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.lock(),
                    size: 20,
                    color: colors.mediumGray,
                  ),
                  suffixIcon: IconButton(
                    icon: PhosphorIcon(
                      _obscurePassword
                          ? PhosphorIcons.eye()
                          : PhosphorIcons.eyeSlash(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(authController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite sua senha';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 12),
              
              // Link Esqueci minha senha
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Mensagem de erro
              if (authController.error != null) ...[
                ErrorMessage(
                  message: authController.error!,
                  showRetry: false,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .shake(hz: 4, curve: Curves.easeInOut),
                const SizedBox(height: 24),
              ],
              
              // Botão Entrar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: authController.isLoading
                      ? null
                      : () => _handleLogin(authController),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entrar'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Link para criar conta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem uma conta? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.mediumGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Criar conta',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthController authController) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await authController.signInWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    // Só navega se autenticou com sucesso E não há erro
    if (authController.isAuthenticated && authController.error == null) {
      final user = authController.currentUser;
      
      if (user == null) return;
      
      // Verifica se o email foi verificado
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (!(firebaseUser?.emailVerified ?? false)) {
        // Email não verificado → EmailVerificationScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const EmailVerificationScreen(),
          ),
          (route) => false, // Remove todas as rotas anteriores
        );
        return;
      }
      
      // Verifica se precisa completar perfil
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
        
        // Mostra mensagem de sucesso
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Login realizado com sucesso! Bem-vindo de volta!'),
                backgroundColor: AppConstants.colors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
    // Se houver erro, fica na mesma tela e mostra o erro
  }
}
