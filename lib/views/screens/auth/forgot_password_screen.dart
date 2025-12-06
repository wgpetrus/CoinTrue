import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/constants.dart';
import '../../widgets/widgets.dart';

/// Tela de Recuperação de Senha
/// 
/// Permite que usuários solicitem um email de recuperação de senha.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    // Limpa erros ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().clearError();
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
                  message: 'Enviando email...',
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
              // Ícone
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.lightGray,
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(
                    PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
                    size: 40,
                    color: colors.yellowDark,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Título
              Text(
                _emailSent ? 'Email Enviado!' : 'Esqueceu sua senha?',
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
              
              const SizedBox(height: 12),
              
              // Descrição
              Text(
                _emailSent
                    ? 'Enviamos um link de recuperação para ${_emailController.text}. Verifique sua caixa de entrada e spam.'
                    : 'Digite seu email e enviaremos um link para você redefinir sua senha.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.mediumGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 32),
              
              if (!_emailSent) ...[
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
                  textInputAction: TextInputAction.done,
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
                
                // Botão Enviar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authController.isLoading
                        ? null
                        : () => _handleSendEmail(authController),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colors.darkGray,
                    ),
                    child: const Text('Enviar Link de Recuperação'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
              ] else ...[
                // Botão Voltar ao Login
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colors.darkGray,
                    ),
                    child: const Text('Voltar ao Login'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Botão Reenviar Email
                TextButton(
                  onPressed: () {
                    setState(() => _emailSent = false);
                  },
                  child: Text(
                    'Não recebeu? Enviar novamente',
                    style: TextStyle(
                      color: colors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
              ],
              
              const SizedBox(height: 24),
              
              // Link para voltar
              if (!_emailSent)
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Voltar ao login',
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendEmail(AuthController authController) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await authController.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted && authController.error == null) {
        setState(() => _emailSent = true);
      }
    } catch (e) {
      // Erro já é tratado pelo controller
      debugPrint('Error in forgot password: $e');
    }
  }
}
