import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../../utils/asset_loader.dart';

/// Tela de Bloqueio Biométrico
/// 
/// Exibida quando o usuário tem biometria configurada.
/// Bloqueia o acesso ao app até que a autenticação biométrica seja bem-sucedida.
class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Solicita biometria automaticamente ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final authController = context.read<AuthController>();

    try {
      final authenticated = await authController.biometricService.authenticate(
        reason: 'Autentique-se para acessar o app',
      );

      if (mounted) {
        if (authenticated) {
          // Sucesso - permite acesso
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isAuthenticating = false;
            _errorMessage = 'Autenticação cancelada';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Erro na autenticação biométrica';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    return WillPopScope(
      // Impede voltar sem autenticar
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header com logo
                  Column(
                    children: [
                      AssetLoader.loadAppLogo(
                        width: 100,
                        height: 100,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'CoinTrue',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colors.darkGray,
                          letterSpacing: -0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: -0.2, duration: 400.ms),
                    ],
                  ),
                  
                  // Conteúdo central
                  Column(
                    children: [
                      // Ícone de biometria com efeito pulsante
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primary.withOpacity(0.2),
                              colors.secondary.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colors.primary, colors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                PhosphorIcons.fingerprint(PhosphorIconsStyle.fill),
                                size: 56,
                                color: colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(reverse: true),
                          )
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.05, 1.05),
                            duration: 2000.ms,
                          ),
                      
                      const SizedBox(height: 48),
                      
                      // Título
                      Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.darkGray,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.3, duration: 400.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Descrição
                      Text(
                        'Toque no sensor para\ndesbloquear o app',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.mediumGray,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 400.ms)
                          .slideY(begin: 0.3, duration: 400.ms),
                    ],
                  ),
                  
                  // Footer com botões
                  Column(
                    children: [
                
                      // Mensagem de erro
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.error.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.error.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PhosphorIcon(
                                  PhosphorIcons.warning(PhosphorIconsStyle.fill),
                                  size: 24,
                                  color: colors.error,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: colors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .shake(hz: 4, curve: Curves.easeInOut)
                            .slideY(begin: 0.2, duration: 300.ms),
                      
                      // Botão Tentar Novamente
                      if (!_isAuthenticating)
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _authenticate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.fingerprint(PhosphorIconsStyle.fill),
                                  size: 24,
                                  color: colors.white,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Autenticar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .slideY(begin: 0.3, duration: 400.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Botão Sair
                      TextButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Text(
                                'Sair do App?',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colors.darkGray,
                                ),
                              ),
                              content: Text(
                                'Você precisa autenticar com biometria para acessar o app.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.mediumGray,
                                  height: 1.5,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colors.mediumGray,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Sair',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true && mounted) {
                            await context.read<AuthController>().signOut();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.signOut(),
                              size: 18,
                              color: colors.mediumGray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sair do App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 400.ms),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
