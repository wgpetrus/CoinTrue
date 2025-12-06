import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/auth_controller.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../utils/constants.dart';
import '../onboarding/biometric_setup_screen.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/user_profile_repository.dart';
import '../../widgets/profile/profile_settings_item.dart';
import '../../widgets/profile/profile_settings_toggle.dart';

/// Tela de Perfil/Configurações
/// 
/// Exibe:
/// - Header com avatar, nome e email
/// - Seção Conta
/// - Seção Segurança
/// - Seção Preferências
/// - Seção Sobre
/// - Botões de Sair e Excluir Conta
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authController = context.read<AuthController>();
    final userId = authController.currentUser?.id;
    
    if (userId == null) return;
    
    try {
      final repository = UserProfileRepository();
      final profile = await repository.getProfile(userId);
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Erro ao carregar perfil, continua sem dados
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(
            color: colors.darkGray,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com Avatar
            _buildHeader(context, user, _userProfile, colors),
            
            const SizedBox(height: 32),
            
            // Seção Conta
            _buildSection(
              context,
              title: 'CONTA',
              items: [
                ProfileSettingsItem(
                  icon: PhosphorIcons.user(),
                  title: 'Informações Pessoais',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                    
                    // Se houve atualização, recarrega o perfil
                    if (result == true) {
                      _loadUserProfile();
                    }
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.bell(),
                  title: 'Notificações',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Seção Segurança
            _buildSection(
              context,
              title: 'SEGURANÇA',
              items: [
                // Alterar Senha (apenas para contas email/senha)
                if (_isEmailPasswordAccount(authController)) ...[
                  ProfileSettingsItem(
                    icon: PhosphorIcons.key(),
                    title: 'Alterar Senha',
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
                ProfileSettingsToggle(
                  icon: PhosphorIcons.fingerprint(),
                  title: 'Biometria',
                  subtitle: 'Usar impressão digital ou Face ID',
                  value: authController.biometricEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // Navegar para configuração de biometria
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BiometricSetupScreen(),
                        ),
                      );
                      if (result == true) {
                        // Biometria ativada
                      }
                    } else {
                      // Desativar biometria
                      await authController.disableBiometric();
                    }
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.shieldCheck(),
                  title: 'Autenticação em 2 Fatores',
                  subtitle: 'Em breve',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.devices(),
                  title: 'Dispositivos Conectados',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Seção Preferências
            _buildSection(
              context,
              title: 'PREFERÊNCIAS',
              items: [
                ProfileSettingsItem(
                  icon: PhosphorIcons.currencyCircleDollar(),
                  title: 'Moeda Padrão',
                  trailing: Text(
                    'BRL',
                    style: TextStyle(
                      color: colors.mediumGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.palette(),
                  title: 'Tema',
                  trailing: Text(
                    'Claro',
                    style: TextStyle(
                      color: colors.mediumGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.translate(),
                  title: 'Idioma',
                  trailing: Text(
                    'Português',
                    style: TextStyle(
                      color: colors.mediumGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Seção Sobre
            _buildSection(
              context,
              title: 'SOBRE',
              items: [
                ProfileSettingsItem(
                  icon: PhosphorIcons.fileText(),
                  title: 'Termos de Uso',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.lock(),
                  title: 'Política de Privacidade',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.question(),
                  title: 'Central de Ajuda',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.chatCircle(),
                  title: 'Falar com Suporte',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                ProfileSettingsItem(
                  icon: PhosphorIcons.info(),
                  title: 'Versão do App',
                  trailing: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: colors.mediumGray,
                      fontSize: 14,
                    ),
                  ),
                  onTap: null, // Não clicável
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botão Sair
            OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.signOut(PhosphorIconsStyle.bold),
                    color: colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sair',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Botão Excluir Conta
            TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              style: TextButton.styleFrom(
                foregroundColor: colors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Excluir Conta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, UserProfile? userProfile, AppColors colors) {
    // Usa o nome completo do perfil se disponível, senão usa displayName do Auth
    final displayName = userProfile?.fullName ?? user?.displayName ?? 'Usuário';
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2D2D2D),
            Color(0xFF1A1A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.yellow, colors.yellowDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.yellow.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Nome (usa nome completo do perfil)
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 6),
          
          // Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botão Editar Perfil
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.yellow, colors.yellowDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.yellow.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  
                  // Se houve atualização, recarrega o perfil
                  if (result == true) {
                    _loadUserProfile();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Editar Perfil',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    final colors = AppConstants.colors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.mediumGray,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.white,
            border: Border.all(color: colors.lightGray),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  /// Verifica se a conta é do tipo email/senha (não social login)
  bool _isEmailPasswordAccount(AuthController authController) {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;
    
    // Verifica os provedores de autenticação
    final providers = firebaseUser.providerData.map((info) => info.providerId).toList();
    
    // Se tem 'password' como provider, é conta email/senha
    final hasPasswordProvider = providers.contains('password');
    
    // Se tem apenas 'google.com' ou 'apple.com', é social login
    final hasOnlySocialLogin = (providers.contains('google.com') || providers.contains('apple.com')) && 
                               !hasPasswordProvider;
    
    return hasPasswordProvider && !hasOnlySocialLogin;
  }

  void _showChangePasswordDialog(BuildContext context) {
    final colors = AppConstants.colors;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.key(PhosphorIconsStyle.fill),
              color: colors.yellow,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Alterar Senha'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Digite sua senha atual e escolha uma nova senha.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha Atual',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.lock(),
                    color: colors.mediumGray,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.lockKey(),
                    color: colors.mediumGray,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  prefixIcon: PhosphorIcon(
                    PhosphorIcons.lockKey(),
                    color: colors.mediumGray,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              currentPasswordController.dispose();
              newPasswordController.dispose();
              confirmPasswordController.dispose();
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;
              
              if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Preencha todos os campos'),
                    backgroundColor: colors.error,
                  ),
                );
                return;
              }
              
              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('As senhas não coincidem'),
                    backgroundColor: colors.error,
                  ),
                );
                return;
              }
              
              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('A senha deve ter pelo menos 6 caracteres'),
                    backgroundColor: colors.error,
                  ),
                );
                return;
              }
              
              // Captura navigator e authController ANTES de fechar o dialog
              final navigator = Navigator.of(context, rootNavigator: true);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final authController = context.read<AuthController>();
              
              navigator.pop(); // Fecha o dialog de input
              
              // Aguarda um frame
              await Future.delayed(const Duration(milliseconds: 100));
              
              // Mostra loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
                    ),
                  ),
                ),
              );
              
              // Aguarda um frame
              await Future.delayed(const Duration(milliseconds: 100));
              
              try {
                debugPrint('🔵 ProfileScreen: Calling updatePassword...');
                await authController.updatePassword(currentPassword, newPassword);
                debugPrint('🔵 ProfileScreen: Password updated successfully!');
                
                // Aguarda processamento
                await Future.delayed(const Duration(milliseconds: 200));
                
                navigator.pop(); // Fecha loading
                
                await Future.delayed(const Duration(milliseconds: 100));
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('Senha alterada com sucesso!'),
                    backgroundColor: colors.success,
                  ),
                );
              } catch (e) {
                debugPrint('🔵 ProfileScreen: Caught error: $e');
                navigator.pop(); // Fecha loading
                
                await Future.delayed(const Duration(milliseconds: 100));
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro: $e'),
                    backgroundColor: colors.error,
                  ),
                );
              } finally {
                currentPasswordController.dispose();
                newPasswordController.dispose();
                confirmPasswordController.dispose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.yellow,
              foregroundColor: colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final colors = AppConstants.colors;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.info(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text('Em breve!'),
          ],
        ),
        backgroundColor: colors.mediumGray,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colors = AppConstants.colors;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.signOut(PhosphorIconsStyle.fill),
              color: colors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Sair'),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final authController = context.read<AuthController>();
              
              navigator.pop(); // Fecha o dialog
              
              // Faz logout
              await authController.signOut();
              
              // Navega para login (remove todas as telas anteriores)
              navigator.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final colors = AppConstants.colors;
    final passwordController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.lock(PhosphorIconsStyle.fill),
              color: colors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Confirme sua senha'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Por segurança, digite sua senha para confirmar a exclusão da conta.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      // TODO: Validar senha com Firebase antes de excluir
      await _proceedWithDeletion(context);
    }
    
    passwordController.dispose();
  }
  
  Future<void> _authenticateWithBiometric(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authController = context.read<AuthController>();
    final colors = AppConstants.colors;
    
    try {
      final authenticated = await authController.biometricService.authenticate(
        reason: 'Autentique-se para confirmar a exclusão da conta',
      );
      
      if (authenticated && context.mounted) {
        // Chama o método que funciona corretamente
        await _proceedWithDeletion(context);
      } else {
        // Usuário cancelou ou falhou
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Autenticação cancelada'),
            backgroundColor: colors.mediumGray,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro na autenticação: $e'),
          backgroundColor: colors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> _proceedWithDeletion(BuildContext context) async {
    print('🔴 ProfileScreen: Starting account deletion...');
    
    // Captura o navigator e authController ANTES de qualquer operação async
    final navigator = Navigator.of(context, rootNavigator: true);
    final authController = context.read<AuthController>();
    
    // Mostra loading
    print('🔴 ProfileScreen: Showing loading dialog...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.colors.yellow),
          ),
        ),
      ),
    );
    
    // Aguarda um frame para garantir que o dialog foi mostrado
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      // Exclui conta
      print('🔴 ProfileScreen: Calling deleteAccount...');
      await authController.deleteAccount();
      print('🔴 ProfileScreen: Account deleted successfully');
      
      // Aguarda processamento do Firebase
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Fecha loading usando o navigator capturado
      print('🔴 ProfileScreen: Closing loading dialog...');
      navigator.pop();
      
      // Aguarda um frame
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Navega para login usando o navigator capturado
      print('🔴 ProfileScreen: Navigating to login...');
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      
    } catch (e) {
      print('🔴 ProfileScreen: Error deleting account: $e');
      
      // Fecha loading usando o navigator capturado
      navigator.pop();
      
      // Para mostrar erro, precisamos de um novo context
      // Aguarda um frame e tenta mostrar o erro
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Navega para login mesmo com erro
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  void _showDeleteAccountDialog(BuildContext context) async {
    final colors = AppConstants.colors;
    
    // Validação de saldo
    final walletController = context.read<WalletController>();
    final portfolioController = context.read<PortfolioController>();
    
    final hasBalance = walletController.balance > 0;
    final hasCryptos = portfolioController.hasAssets;
    
    if (hasBalance || hasCryptos) {
      // Bloqueia exclusão se houver saldo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                color: colors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('Não é possível excluir'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sua conta possui saldo ou criptomoedas. Para excluir sua conta, você precisa:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              if (hasCryptos) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.arrowRight(),
                      size: 16,
                      color: colors.mediumGray,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Vender todas as suas criptomoedas'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (hasBalance) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.arrowRight(),
                      size: 16,
                      color: colors.mediumGray,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Sacar todo o saldo (R\$ ${walletController.balance.toStringAsFixed(2)})'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.info(PhosphorIconsStyle.fill),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Isso protege você de perder seu dinheiro acidentalmente.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.yellow,
                foregroundColor: colors.darkGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Se não houver saldo, mostra dialog de confirmação normal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.warning(PhosphorIconsStyle.fill),
              color: colors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Excluir Conta'),
          ],
        ),
        content: const Text(
          'Esta ação é irreversível! Todos os seus dados serão permanentemente excluídos.\n\nPor segurança, você precisará fazer login novamente para confirmar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Fecha o dialog de confirmação
              Navigator.pop(context);
              
              // Chama o método que funciona corretamente
              await _proceedWithDeletion(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

