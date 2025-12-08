import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../../utils/asset_loader.dart';
import '../../../utils/platform_helper.dart';
import '../../widgets/widgets.dart';

/// Tela de Configuração de Biometria
/// 
/// Exibe uma interface explicativa sobre os benefícios da autenticação biométrica
/// e permite que o usuário ative ou pule a configuração.
/// Trata erros como dispositivo sem suporte ou biometria não configurada.
/// 
/// Requisitos: 2.1, 2.2, 2.3, 10.1
class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  bool _biometricActivated = false;

  @override
  Widget build(BuildContext context) {
    // Se a plataforma não suporta biometria, permite pular
    if (!PlatformHelper.supportsBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Seu dispositivo não suporta biometria. Você pode continuar sem ela.',
              ),
              backgroundColor: AppConstants.colors.mediumGray,
              duration: const Duration(seconds: 4),
            ),
          );
          // Navega direto para home se não suporta biometria
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
      return Scaffold(
        backgroundColor: AppConstants.colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.colors.white,
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          return LoadingOverlay(
            isLoading: authController.isLoading,
            message: AppConstants.strings.processing,
            child: _biometricActivated
                ? _buildSuccessBody(context, authController)
                : _buildBody(context, authController),
          );
        },
      ),
    );
  }

  /// Constrói a tela de sucesso após ativar biometria
  Widget _buildSuccessBody(BuildContext context, AuthController authController) {
    final colors = AppConstants.colors;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone de sucesso
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: colors.success,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 32),
            
            // Título
            Text(
              'Biometria Ativada!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // Descrição
            Text(
              'Agora você pode fazer login de forma rápida e segura usando sua biometria.',
              style: TextStyle(
                fontSize: 16,
                color: colors.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.2, duration: 400.ms),
            
            const SizedBox(height: 48),
            
            // Botão Continuar
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  /// Constrói o corpo da tela
  Widget _buildBody(BuildContext context, AuthController authController) {
    final colors = AppConstants.colors;
    
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
                      // Ilustração/ícone de biometria
                      _buildBiometricIllustration(colors, isTablet),
                      SizedBox(height: isTablet ? 48 : 32),
                      
                      // Título
                      _buildTitle(colors),
                      const SizedBox(height: 16),
                      
                      // Descrição dos benefícios
                      _buildDescription(colors),
                      SizedBox(height: isTablet ? 48 : 32),
                      
                      // Mensagem de erro (se houver)
                      if (authController.error != null) ...[
                        ErrorMessage(
                          message: authController.error!,
                          onRetry: () {
                            authController.clearError();
                          },
                          showRetry: true,
                          retryButtonText: 'Fechar',
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Botão "Ativar Biometria" (obrigatório)
                      _buildEnableButton(authController),
                      const SizedBox(height: 16),
                      
                      // Mensagem informativa
                      Text(
                        'A biometria é obrigatória para sua segurança. Você poderá desativá-la depois nas configurações.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.mediumGray,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
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

  /// Constrói a ilustração/ícone de biometria
  Widget _buildBiometricIllustration(AppColors colors, bool isTablet) {
    final size = isTablet ? 180.0 : 140.0;
    final iconSize = isTablet ? 110.0 : 85.0;
    
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AssetLoader.loadBiometricLogo(
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }

  /// Constrói o título
  Widget _buildTitle(AppColors colors) {
    return Text(
      'Configure sua Biometria',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colors.darkGray,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Constrói a descrição dos benefícios
  Widget _buildDescription(AppColors colors) {
    return Column(
      children: [
        Text(
          'Para garantir a segurança dos seus investimentos, a autenticação biométrica é obrigatória.',
          style: TextStyle(
            fontSize: 16,
            color: colors.darkGray.withValues(alpha: 0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Lista de benefícios
        _buildBenefitsList(colors),
      ],
    );
  }

  /// Constrói a lista de benefícios
  Widget _buildBenefitsList(AppColors colors) {
    final benefits = [
      {
        'icon': Icons.speed,
        'title': 'Acesso Rápido',
        'description': 'Entre em segundos sem digitar senha',
      },
      {
        'icon': Icons.security,
        'title': 'Mais Seguro',
        'description': 'Sua biometria é única e protegida',
      },
      {
        'icon': Icons.touch_app,
        'title': 'Fácil de Usar',
        'description': 'Apenas um toque ou olhar',
      },
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: colors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Constrói o botão "Ativar Biometria"
  Widget _buildEnableButton(AuthController authController) {
    final colors = AppConstants.colors;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authController.isLoading 
            ? null 
            : () => _handleEnableBiometric(authController),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          disabledBackgroundColor: colors.darkGray.withValues(alpha: 0.3),
          foregroundColor: colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: authController.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.white),
                ),
              )
            : Text(
                'Ativar Biometria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.white,
                ),
              ),
      ),
    );
  }

  /// Constrói o botão "Agora Não" - REMOVIDO: Biometria é obrigatória
  Widget _buildSkipButton(AuthController authController) {
    // Biometria é obrigatória no primeiro acesso
    // Usuário só pode desativar depois de entrar no app
    return const SizedBox.shrink();
  }

  /// Manipula a ativação da biometria
  Future<void> _handleEnableBiometric(AuthController authController) async {
    // Limpa erro anterior
    authController.clearError();
    
    await authController.enableBiometric();
    
    if (!mounted) return;
    
    // Se ativou com sucesso
    if (authController.biometricEnabled && authController.error == null) {
      setState(() => _biometricActivated = true);
    }
    // Se houver erro, ele já está sendo exibido pelo ErrorMessage no build
  }


}
