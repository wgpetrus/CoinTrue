import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/theme_helper.dart';
import '../../../models/models.dart';
import '../../../repositories/repositories.dart';

/// Tela de Onboarding - Coleta informações adicionais do usuário
/// 
/// Coletamos informações essenciais para um app de criptomoedas:
/// - Nome Completo
/// - CPF (para conformidade regulatória e KYC)
/// - Data de nascimento (verificação de idade +18)
/// - Telefone (autenticação 2FA e recuperação de conta)
/// - Estado (regulamentações locais)
/// - Ocupação (conformidade)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  String? _selectedState;
  String? _selectedOccupation;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final List<String> _brazilianStates = [
    'Acre (AC)',
    'Alagoas (AL)',
    'Amapá (AP)',
    'Amazonas (AM)',
    'Bahia (BA)',
    'Ceará (CE)',
    'Distrito Federal (DF)',
    'Espírito Santo (ES)',
    'Goiás (GO)',
    'Maranhão (MA)',
    'Mato Grosso (MT)',
    'Mato Grosso do Sul (MS)',
    'Minas Gerais (MG)',
    'Pará (PA)',
    'Paraíba (PB)',
    'Paraná (PR)',
    'Pernambuco (PE)',
    'Piauí (PI)',
    'Rio de Janeiro (RJ)',
    'Rio Grande do Norte (RN)',
    'Rio Grande do Sul (RS)',
    'Rondônia (RO)',
    'Roraima (RR)',
    'Santa Catarina (SC)',
    'São Paulo (SP)',
    'Sergipe (SE)',
    'Tocantins (TO)',
  ];

  final List<String> _occupations = [
    'Estudante',
    'Empregado CLT',
    'Servidor Público',
    'Autônomo',
    'Empresário',
    'Profissional Liberal',
    'Aposentado',
    'Desempregado',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    // Pré-preenche o nome se disponível
    final authController = context.read<AuthController>();
    _nameController.text = authController.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
        title: const Text('Complete seu Perfil'),
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(),
            size: 24,
            color: colors.darkGray,
          ),
          onPressed: () async {
            // Confirma se quer sair sem completar
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Sair sem completar?'),
                content: const Text(
                  'Você precisará completar seu perfil na próxima vez que fizer login.',
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
            
            if (confirm == true && context.mounted) {
              // Faz logout e volta para login
              await context.read<AuthController>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Explicação
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
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                        size: 24,
                        color: colors.info,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Para sua segurança e conformidade regulatória, precisamos de algumas informações.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.darkGray,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // Nome Completo
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    hintText: 'Digite seu nome completo',
                    prefixIcon: PhosphorIcon(
                      PhosphorIcons.user(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite seu nome completo';
                    }
                    if (value.trim().length < 3) {
                      return 'Nome deve ter no mínimo 3 caracteres';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // CPF
                TextFormField(
                  controller: _cpfController,
                  decoration: InputDecoration(
                    labelText: 'CPF',
                    hintText: '000.000.000-00',
                    prefixIcon: PhosphorIcon(
                      PhosphorIcons.identificationCard(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CpfInputFormatter()],
                  validator: Validators.cpf,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Data de Nascimento
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Data de Nascimento',
                    hintText: 'DD/MM/AAAA',
                    prefixIcon: PhosphorIcon(
                      PhosphorIcons.calendar(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [DateInputFormatter()],
                  validator: Validators.birthDate,
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Telefone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(00) 00000-0000',
                    prefixIcon: PhosphorIcon(
                      PhosphorIcons.phone(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  validator: Validators.phone,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Estado
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: colors.white,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) => Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.lightGray,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Selecione seu estado',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.darkGray,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: _brazilianStates.length,
                                itemBuilder: (context, index) {
                                  final state = _brazilianStates[index];
                                  return ListTile(
                                    title: Text(
                                      state,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colors.darkGray,
                                      ),
                                    ),
                                    trailing: _selectedState == state
                                        ? PhosphorIcon(
                                            PhosphorIcons.check(PhosphorIconsStyle.bold),
                                            color: colors.primary,
                                            size: 24,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() => _selectedState = state);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: PhosphorIcon(
                        PhosphorIcons.mapPin(),
                        size: 20,
                        color: colors.mediumGray,
                      ),
                      suffixIcon: PhosphorIcon(
                        PhosphorIcons.caretDown(),
                        size: 20,
                        color: colors.mediumGray,
                      ),
                      errorText: _selectedState == null && _acceptedTerms
                          ? 'Selecione seu estado'
                          : null,
                    ),
                    child: Text(
                      _selectedState ?? 'Selecione seu estado',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedState != null
                            ? colors.darkGray
                            : colors.mediumGray,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Ocupação
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: colors.white,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.5,
                        minChildSize: 0.3,
                        maxChildSize: 0.7,
                        expand: false,
                        builder: (context, scrollController) => Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.lightGray,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Selecione sua ocupação',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.darkGray,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: _occupations.length,
                                itemBuilder: (context, index) {
                                  final occupation = _occupations[index];
                                  return ListTile(
                                    title: Text(
                                      occupation,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colors.darkGray,
                                      ),
                                    ),
                                    trailing: _selectedOccupation == occupation
                                        ? PhosphorIcon(
                                            PhosphorIcons.check(PhosphorIconsStyle.bold),
                                            color: colors.primary,
                                            size: 24,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() => _selectedOccupation = occupation);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Ocupação',
                      prefixIcon: PhosphorIcon(
                        PhosphorIcons.briefcase(),
                        size: 20,
                        color: colors.mediumGray,
                      ),
                      suffixIcon: PhosphorIcon(
                        PhosphorIcons.caretDown(),
                        size: 20,
                        color: colors.mediumGray,
                      ),
                      errorText: _selectedOccupation == null && _acceptedTerms
                          ? 'Selecione sua ocupação'
                          : null,
                    ),
                    child: Text(
                      _selectedOccupation ?? 'Selecione sua ocupação',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedOccupation != null
                            ? colors.darkGray
                            : colors.mediumGray,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Checkbox de termos
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: colors.primary,
                  checkColor: colors.darkGray,
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.darkGray,
                      ),
                      children: [
                        const TextSpan(text: 'Aceito os '),
                        TextSpan(
                          text: 'Termos de Uso',
                          style: TextStyle(
                            color: colors.info,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' e '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            color: colors.info,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Botão Continuar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _acceptedTerms ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colors.onPrimary,
                    ),
                    child: const Text('Continuar'),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.2, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
        ),
        // Loading overlay com design melhorado
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone animado
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                            ),
                          ),
                          PhosphorIcon(
                            PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.fill),
                            size: 32,
                            color: colors.primaryDark,
                          ),
                        ],
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          duration: 1000.ms,
                        ),
                    
                    const SizedBox(height: 24),
                    
                    // Título
                    Text(
                      'Salvando seus dados',
                      style: TextStyle(
                        color: colors.darkGray,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      'Aguarde um momento...',
                      style: TextStyle(
                        color: colors.mediumGray,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOut),
            ),
          ),
      ],
    );
  }

  /// Gera um ID de conta mais bonito e legível
  /// Formato: KMLN-XXXX-XXXX (ex: KMLN-A7B2-C9D4)
  String _generatePrettyAccountId(String userId) {
    if (userId.isEmpty) return 'KMLN-0000-0000';
    
    // Usa hash do userId para gerar um ID consistente
    final hash = userId.hashCode.abs();
    final random = Random(hash);
    
    String generateSegment() {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Remove confusos: I, O, 0, 1
      return List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    }
    
    return 'KMLN-${generateSegment()}-${generateSegment()}';
  }

  /// Converte data DD/MM/AAAA para DateTime
  DateTime? _parseBirthDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida campos obrigatórios
    if (_selectedState == null || _selectedOccupation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha todos os campos obrigatórios'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    final colors = context.colors;

    setState(() => _isLoading = true);

    // Salvar informações no Firestore
    try {
      final authController = context.read<AuthController>();
      final userId = authController.currentUser?.id;
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      debugPrint('Salvando dados do usuário: $userId');

      // Converte data de nascimento
      final birthDate = _parseBirthDate(_birthDateController.text.trim());
      if (birthDate == null) {
        throw Exception('Data de nascimento inválida');
      }

      // Gera ID bonito da conta
      final accountId = _generatePrettyAccountId(userId);

      // Cria o perfil
      final profile = UserProfile(
        userId: userId,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: birthDate,
        state: _selectedState!,
        occupation: _selectedOccupation!,
        accountId: accountId,
        profileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Salva no Firestore usando o repository
      final repository = UserProfileRepository();
      await repository.saveProfile(profile);

      // IMPORTANTE: Atualiza também a coleção 'users' para marcar profileComplete como true
      // Usa set com merge para criar o documento se não existir
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Dados salvos com sucesso!');

      if (mounted) {
        setState(() => _isLoading = false);
        
        // Navega para BiometricSetupScreen para oferecer configuração de biometria
        Navigator.of(context).pushReplacementNamed('/biometric-setup');
      }
    } catch (e) {
      debugPrint('Erro ao salvar dados: $e');
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar dados: $e'),
            backgroundColor: colors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

}
