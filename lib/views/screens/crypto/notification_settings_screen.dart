import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helper.dart';
import '../../../controllers/controllers.dart';
import '../../../models/models.dart';

/// Tela de Configurações de Notificações
/// 
/// Permite o usuário configurar:
/// - Resumo do Portfólio (frequência e horário)
/// - Variação de Preço (threshold)
/// - Alertas de Mercado (em breve)
/// - Alertas de Preço Alvo (em breve)
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Estado de loading
  bool _isLoading = false;
  
  // Resumo do Portfólio
  bool _portfolioSummaryEnabled = false;
  String _portfolioFrequency = 'daily'; // daily, weekly
  String _portfolioTime = 'morning'; // morning, afternoon, evening
  
  // Variação de Preço
  bool _priceVariationEnabled = false;
  double _priceThreshold = 5.0; // 5%
  bool _onlyPortfolio = true; // Apenas criptos do portfólio
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  /// Carrega preferências salvas
  void _loadPreferences() {
    final notificationController = context.read<NotificationController>();
    final prefs = notificationController.preferences;
    
    setState(() {
      _portfolioSummaryEnabled = prefs.portfolioSummaryEnabled;
      _portfolioFrequency = prefs.portfolioFrequency;
      _portfolioTime = prefs.portfolioTime;
      _priceVariationEnabled = prefs.priceVariationEnabled;
      _priceThreshold = prefs.priceThreshold;
      _onlyPortfolio = prefs.onlyPortfolio;
    });
  }
  
  /// Salva preferências
  Future<void> _savePreferences() async {
    final authController = context.read<AuthController>();
    final notificationController = context.read<NotificationController>();
    final userId = authController.currentUser?.id;
    
    if (userId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newPreferences = NotificationPreferences(
        portfolioSummaryEnabled: _portfolioSummaryEnabled,
        portfolioFrequency: _portfolioFrequency,
        portfolioTime: _portfolioTime,
        priceVariationEnabled: _priceVariationEnabled,
        priceThreshold: _priceThreshold,
        onlyPortfolio: _onlyPortfolio,
      );
      
      await notificationController.updatePreferences(userId, newPreferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Preferências salvas!'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  /// Solicita permissão e ativa notificação
  Future<void> _handleToggle(bool value, Function(bool) onUpdate) async {
    if (value) {
      // Verifica/solicita permissão
      final notificationController = context.read<NotificationController>();
      
      if (!notificationController.hasPermission) {
        final granted = await notificationController.requestPermission();
        
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Permissão de notificações negada'),
                backgroundColor: context.colors.error,
              ),
            );
          }
          return;
        }
      }
    }
    
    onUpdate(value);
    await _savePreferences();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(
          'Notificações',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.colors.onBackground,
          ),
        ),
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            size: 24,
            color: context.colors.onBackground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Resumo do Portfólio
          _buildSection(
            title: 'RESUMO DO PORTFÓLIO',
            children: [
              _buildToggle(
                icon: PhosphorIcons.briefcase(),
                title: 'Resumo Diário',
                subtitle: 'Receba um resumo do seu portfólio',
                value: _portfolioSummaryEnabled,
                onChanged: (value) => _handleToggle(value, (v) {
                  setState(() => _portfolioSummaryEnabled = v);
                }),
              ),
              if (_portfolioSummaryEnabled) ...[
                const SizedBox(height: 16),
                _buildFrequencySelector(),
                const SizedBox(height: 16),
                _buildTimeSelector(),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Variação de Preço
          _buildSection(
            title: 'VARIAÇÃO DE PREÇO',
            children: [
              _buildToggle(
                icon: PhosphorIcons.trendUp(),
                title: 'Alertas de Variação',
                subtitle: 'Notificações sobre mudanças de preço',
                value: _priceVariationEnabled,
                onChanged: (value) => _handleToggle(value, (v) {
                  setState(() => _priceVariationEnabled = v);
                }),
              ),
              if (_priceVariationEnabled) ...[
                const SizedBox(height: 16),
                _buildThresholdSelector(),
                const SizedBox(height: 16),
                _buildToggle(
                  icon: PhosphorIcons.wallet(),
                  title: 'Apenas Meu Portfólio',
                  subtitle: 'Alertas só para criptos que você possui',
                  value: _onlyPortfolio,
                  onChanged: (value) {
                    setState(() => _onlyPortfolio = value);
                    _savePreferences();
                  },
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Alertas de Mercado (Em breve)
          _buildSection(
            title: 'ALERTAS DE MERCADO',
            children: [
              _buildComingSoonItem(
                icon: PhosphorIcons.newspaper(),
                title: 'Notícias do Mercado',
                subtitle: 'Em breve',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Alertas de Preço Alvo (Em breve)
          _buildSection(
            title: 'ALERTAS DE PREÇO',
            children: [
              _buildComingSoonItem(
                icon: PhosphorIcons.target(),
                title: 'Preço Alvo',
                subtitle: 'Em breve',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Botão de Teste (DEBUG)
          if (kDebugMode) ...[
            _buildSection(
              title: 'DEBUG',
              children: [
                _buildDebugButton(
                  icon: PhosphorIcons.testTube(),
                  title: 'Enviar Notificação de Teste',
                  onTap: () async {
                    final notificationController = context.read<NotificationController>();
                    await notificationController.sendTestNotification();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notificação de teste enviada!'),
                          backgroundColor: context.colors.success,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                _buildDebugButton(
                  icon: PhosphorIcons.listBullets(),
                  title: 'Listar Notificações Agendadas',
                  onTap: () async {
                    final notificationController = context.read<NotificationController>();
                    await notificationController.listScheduledNotifications();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Verifique o console para ver as notificações'),
                          backgroundColor: context.colors.info,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final colors = context.colors;
    
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
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildToggle({
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: PhosphorIcon(
                icon,
                size: 20,
                color: colors.onBackground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildComingSoonItem({
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = context.colors;
    
    return Opacity(
      opacity: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: 20,
                  color: colors.onBackground,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFrequencySelector() {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequência',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  label: 'Diário',
                  value: 'daily',
                  groupValue: _portfolioFrequency,
                  onTap: () {
                    setState(() => _portfolioFrequency = 'daily');
                    _savePreferences();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  label: 'Semanal',
                  value: 'weekly',
                  groupValue: _portfolioFrequency,
                  onTap: () {
                    setState(() => _portfolioFrequency = 'weekly');
                    _savePreferences();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSelector() {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horário',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  label: 'Manhã',
                  value: 'morning',
                  groupValue: _portfolioTime,
                  onTap: () {
                    setState(() => _portfolioTime = 'morning');
                    _savePreferences();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  label: 'Tarde',
                  value: 'afternoon',
                  groupValue: _portfolioTime,
                  onTap: () {
                    setState(() => _portfolioTime = 'afternoon');
                    _savePreferences();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  label: 'Noite',
                  value: 'evening',
                  groupValue: _portfolioTime,
                  onTap: () {
                    setState(() => _portfolioTime = 'evening');
                    _savePreferences();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildThresholdSelector() {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variação Mínima',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  label: '3%',
                  value: 3.0,
                  groupValue: _priceThreshold,
                  onTap: () {
                    setState(() => _priceThreshold = 3.0);
                    _savePreferences();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  label: '5%',
                  value: 5.0,
                  groupValue: _priceThreshold,
                  onTap: () {
                    setState(() => _priceThreshold = 5.0);
                    _savePreferences();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  label: '10%',
                  value: 10.0,
                  groupValue: _priceThreshold,
                  onTap: () {
                    setState(() => _priceThreshold = 10.0);
                    _savePreferences();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptionButton<T>({
    required String label,
    required T value,
    required T groupValue,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? colors.onPrimary : colors.onBackground,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDebugButton({
    required PhosphorIconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: 20,
                  color: colors.info,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onBackground,
                ),
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.caretRight(),
              size: 20,
              color: colors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }
}
