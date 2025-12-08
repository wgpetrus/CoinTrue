import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../widgets/widgets.dart';
import 'email_verification_screen.dart';

/// Tela de Registro com Email/Senha
/// 
/// Permite que novos usuários criem uma conta usando email e senha.
/// Valida os campos e exibe erros apropriados.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  message: 'Criando sua conta...',
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
              // Título
              Text(
                'Criar Conta',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.darkGray,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              const SizedBox(height: 8),
              
              Text(
                'Preencha os dados para criar sua conta',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.mediumGray,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 16),
              
              // Aviso sobre email válido
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.info.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.info(PhosphorIconsStyle.fill),
                      size: 20,
                      color: colors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Use um email válido. Você receberá um link de verificação.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.info,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Campo Nome
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Digite seu nome',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.user(),
                    size: 20,
                    color: colors.mediumGray,
                  ),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite seu nome';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 16),
              
              // Campo Sobrenome
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Sobrenome',
                  hintText: 'Digite seu sobrenome',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.user(),
                    size: 20,
                    color: colors.mediumGray,
                  ),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite seu sobrenome';
                  }
                  if (value.trim().length < 2) {
                    return 'Sobrenome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 16),
              
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
                  hintText: '8+ caracteres, maiúscula, número e especial',
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
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite uma senha';
                  }
                  if (value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Deve conter letra maiúscula';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return 'Deve conter letra minúscula';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Deve conter número';
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Deve conter caractere especial';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 16),
              
              // Campo Confirmar Senha
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  hintText: 'Digite a senha novamente',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.lock(),
                    size: 20,
                    color: colors.mediumGray,
                  ),
                  suffixIcon: IconButton(
                    icon: PhosphorIcon(
                      _obscureConfirmPassword
                          ? PhosphorIcons.eye()
                          : PhosphorIcons.eyeSlash(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme sua senha';
                  }
                  if (value != _passwordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Mensagem de erro
              if (authController.error != null)
                ErrorMessage(
                  message: authController.error!,
                  showRetry: false,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .shake(hz: 4, curve: Curves.easeInOut),
              
              if (authController.error != null) const SizedBox(height: 24),
              
              // Botão Criar Conta
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: authController.isLoading
                      ? null
                      : () => _handleRegister(authController),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Criar Conta'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              // Link para login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem uma conta? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.mediumGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Fazer login',
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

  /// Formata o nome: primeira letra de cada palavra em maiúscula
  String _formatName(String name) {
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _handleRegister(AuthController authController) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Combina nome e sobrenome
    final firstName = _formatName(_firstNameController.text);
    final lastName = _formatName(_lastNameController.text);
    final fullName = '$firstName $lastName';
    
    await authController.signUpWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
      fullName,
    );

    if (!mounted) return;

    // Só navega se autenticou com sucesso E não há erro
    if (authController.isAuthenticated && authController.error == null) {
      // Sucesso - vai para tela de verificação de email
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const EmailVerificationScreen(),
        ),
        (route) => false, // Remove todas as rotas anteriores
      );
    }
    // Se houver erro, fica na mesma tela e mostra o erro
  }
}
