import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/auth_controller.dart';
import '../../../utils/constants.dart';
import '../onboarding/onboarding_screen.dart';

/// Tela de Verificação de Email
/// 
/// Exibida após o registro para que o usuário verifique seu email.
/// Bloqueia o acesso ao app até que o email seja verificado.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isCheckingVerification = false;
  bool _canResendEmail = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    // Limpa erros ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthController>().clearError();
      }
    });
    // Inicia verificação automática a cada 3 segundos
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Inicia verificação automática do status de verificação
  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkEmailVerified();
    });
  }

  /// Verifica se o email foi verificado
  Future<void> _checkEmailVerified() async {
    if (_isCheckingVerification) return;

    setState(() => _isCheckingVerification = true);

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      await user?.reload();
      final updatedUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified == true && mounted) {
        _timer?.cancel();
        
        // Email verificado! Navega para onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    } finally {
      if (mounted) {
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  /// Reenvia o email de verificação
  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _canResendEmail = false;
      _resendCooldown = 60; // 60 segundos de cooldown
    });

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email de verificação reenviado!'),
            backgroundColor: AppConstants.colors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Inicia contagem regressiva
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown > 0) {
          setState(() => _resendCooldown--);
        } else {
          timer.cancel();
          setState(() => _canResendEmail = true);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reenviar email: $e'),
            backgroundColor: AppConstants.colors.error,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _canResendEmail = true;
          _resendCooldown = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final authController = context.watch<AuthController>();
    final userEmail = authController.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícone de email
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(
                    PhosphorIcons.envelopeSimple(PhosphorIconsStyle.fill),
                    size: 60,
                    color: colors.primaryDark,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
              
              const SizedBox(height: 32),
              
              // Título
              Text(
                'Verifique seu Email',
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
              
              const SizedBox(height: 16),
              
              // Descrição
              Text(
                'Enviamos um link de verificação para:',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.mediumGray,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),
              
              const SizedBox(height: 8),
              
              // Email do usuário
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.darkGray,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Instruções
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.info.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.info(PhosphorIconsStyle.fill),
                          size: 20,
                          color: colors.info,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Clique no link do email para verificar sua conta',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.darkGray,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Não esqueça de verificar sua pasta de spam!',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 32),
              
              // Indicador de verificação
              if (_isCheckingVerification)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Verificando...',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.mediumGray,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 300.ms),
              
              const SizedBox(height: 24),
              
              // Botão Reenviar Email
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _canResendEmail ? _resendVerificationEmail : null,
                  icon: PhosphorIcon(
                    PhosphorIcons.paperPlaneTilt(),
                    size: 20,
                    color: _canResendEmail ? colors.darkGray : colors.mediumGray,
                  ),
                  label: Text(
                    _canResendEmail
                        ? 'Reenviar Email'
                        : 'Aguarde ${_resendCooldown}s',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canResendEmail ? colors.darkGray : colors.mediumGray,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _canResendEmail ? colors.veryLightGray : colors.veryLightGray.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 16),
              
              // Botão Verificar Manualmente
              TextButton(
                onPressed: _checkEmailVerified,
                child: Text(
                  'Já verifiquei, continuar',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms),
              
              const Spacer(),
              
              // Botão Sair
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Sair sem verificar?'),
                      content: const Text(
                        'Você precisará verificar seu email antes de acessar o app.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.error,
                          ),
                          child: const Text('Sair'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && mounted) {
                    await authController.signOut();
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  }
                },
                icon: PhosphorIcon(
                  PhosphorIcons.signOut(),
                  size: 16,
                  color: colors.error,
                ),
                label: Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.error,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
