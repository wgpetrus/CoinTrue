import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/constants.dart';

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
        backgroundColor: colors.darkGray,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    AppAssets.logoApp,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: colors.yellow,
                      );
                    },
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
                
                const SizedBox(height: 48),
                
                // Ícone de biometria
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colors.yellow.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.fingerprint(PhosphorIconsStyle.fill),
                      size: 50,
                      color: colors.yellow,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: 1500.ms,
                    ),
                
                const SizedBox(height: 32),
                
                // Título
                Text(
                  'Autenticação Necessária',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.white,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 12),
                
                // Descrição
                Text(
                  'Use sua biometria para acessar o app',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 48),
                
                // Mensagem de erro
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.warning(PhosphorIconsStyle.fill),
                          size: 20,
                          color: colors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .shake(hz: 4, curve: Curves.easeInOut),
                
                if (_errorMessage != null) const SizedBox(height: 24),
                
                // Botão Tentar Novamente
                if (!_isAuthenticating)
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: PhosphorIcon(
                        PhosphorIcons.fingerprint(),
                        size: 20,
                        color: colors.darkGray,
                      ),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.yellow,
                        foregroundColor: colors.darkGray,
                        elevation: 0,
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
                
                // Botão Sair
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Sair do App?'),
                        content: const Text(
                          'Você precisa autenticar com biometria para acessar o app.',
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
                      await context.read<AuthController>().signOut();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    }
                  },
                  icon: PhosphorIcon(
                    PhosphorIcons.signOut(),
                    size: 16,
                    color: colors.white.withValues(alpha: 0.7),
                  ),
                  label: Text(
                    'Sair',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
