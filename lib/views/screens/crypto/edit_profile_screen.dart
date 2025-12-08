import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math';
import '../../../controllers/controllers.dart';
import '../../../utils/constants.dart';
import '../../../models/models.dart';
import '../../../repositories/repositories.dart';

/// Tela de Visualização/Edição de Informações Pessoais
/// 
/// Campos bloqueados (somente visualização):
/// - Nome completo
/// - Email
/// - Data de nascimento
/// 
/// Campos editáveis:
/// - Telefone
/// - Estado
/// - Ocupação
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  // Dados bloqueados (vêm do onboarding)
  String _fullName = '';
  String _email = '';
  DateTime? _birthDate;
  
  // Dados editáveis
  String? _selectedState;
  String? _selectedOccupation;
  
  // ID da conta (gerado de forma bonita)
  String _accountId = '';
  
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
    _loadUserData();
  }

  void _loadUserData() async {
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    
    if (user == null) return;
    
    // Dados do Auth
    _email = user.email;
    
    // Carrega perfil do Firestore
    try {
      final repository = UserProfileRepository();
      final profile = await repository.getProfile(user.id);
      
      if (profile != null && mounted) {
        setState(() {
          // Usa o nome completo do perfil (do onboarding)
          _fullName = profile.fullName;
          _birthDate = profile.birthDate;
          _phoneController.text = profile.phone;
          _selectedState = profile.state;
          _selectedOccupation = profile.occupation;
          _accountId = profile.accountId;
        });
      } else {
        // Perfil não existe (conta antiga), usa valores padrão editáveis
        setState(() {
          _fullName = user.displayName ?? 'Usuário';
          _birthDate = DateTime(1990, 1, 1); // Data padrão
          _phoneController.text = ''; // Vazio para o usuário preencher
          _selectedState = null; // Usuário precisa selecionar
          _selectedOccupation = null; // Usuário precisa selecionar
          _accountId = _generatePrettyAccountId(user.id);
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Fallback
      if (mounted) {
        setState(() {
          _fullName = user.displayName ?? '';
          _accountId = _generatePrettyAccountId(user.id);
        });
      }
    }
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

  String _formatPhone(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    if (numbers.length <= 2) return numbers;
    if (numbers.length <= 7) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2)}';
    }
    if (numbers.length <= 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    }
    return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7, 11)}';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final colors = AppConstants.colors;
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = UserProfileRepository();
      
      // Verifica se o perfil existe
      final existingProfile = await repository.getProfile(user.id);
      
      if (existingProfile == null) {
        // Perfil não existe, cria um novo com os dados disponíveis
        final newProfile = UserProfile(
          userId: user.id,
          fullName: _fullName.isNotEmpty ? _fullName : (user.displayName ?? 'Usuário'),
          phone: _phoneController.text.trim(),
          birthDate: _birthDate ?? DateTime(1990, 1, 1), // Data padrão se não tiver
          state: _selectedState ?? 'São Paulo (SP)', // Estado padrão
          occupation: _selectedOccupation ?? 'Outro', // Ocupação padrão
          accountId: _accountId,
          profileComplete: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await repository.saveProfile(newProfile);
      } else {
        // Perfil existe, atualiza apenas os campos editáveis
        await repository.updateProfile(user.id, {
          'phone': _phoneController.text.trim(),
          'state': _selectedState,
          'occupation': _selectedOccupation,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text('Informações atualizadas!'),
              ],
            ),
            backgroundColor: colors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text('Erro ao atualizar: $e'),
              ],
            ),
            backgroundColor: colors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
          'Informações Pessoais',
          style: TextStyle(
            color: colors.darkGray,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(),
            color: colors.darkGray,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _fullName.isNotEmpty
                              ? _fullName[0].toUpperCase()
                              : _email.isNotEmpty
                                  ? _email[0].toUpperCase()
                                  : '?',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.darkGray,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.white,
                            width: 3,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
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
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: PhosphorIcon(
                                PhosphorIcons.camera(PhosphorIconsStyle.bold),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // DADOS PESSOAIS (Bloqueados)
              Text(
                'DADOS PESSOAIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.mediumGray,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              // Nome Completo (bloqueado)
              _buildLockedField(
                colors: colors,
                icon: PhosphorIcons.user(),
                label: 'Nome Completo',
                value: _fullName,
              ),

              const SizedBox(height: 16),

              // Email (bloqueado)
              _buildLockedField(
                colors: colors,
                icon: PhosphorIcons.envelope(),
                label: 'Email',
                value: _email,
                hint: 'Email não pode ser alterado',
              ),

              const SizedBox(height: 16),

              // Data de Nascimento (bloqueada)
              _buildLockedField(
                colors: colors,
                icon: PhosphorIcons.calendar(),
                label: 'Data de Nascimento',
                value: _birthDate != null
                    ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                    : '-',
              ),

              const SizedBox(height: 32),
              Divider(color: colors.lightGray, height: 1),
              const SizedBox(height: 32),

              // INFORMAÇÕES EDITÁVEIS
              Text(
                'INFORMAÇÕES EDITÁVEIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.mediumGray,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              // Telefone (editável)
              Text(
                'Telefone',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: InputDecoration(
                  hintText: '(00) 00000-0000',
                  filled: true,
                  fillColor: colors.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: PhosphorIcon(
                      PhosphorIcons.phone(),
                      color: colors.mediumGray,
                      size: 24,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: colors.darkGray,
                ),
                onChanged: (value) {
                  final formatted = _formatPhone(value);
                  if (formatted != value) {
                    _phoneController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Estado (editável)
              Text(
                'Estado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () {
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
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.08),
                        colors.primary.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.mapPin(),
                        color: colors.mediumGray,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
                      PhosphorIcon(
                        PhosphorIcons.caretDown(),
                        color: colors.mediumGray,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Ocupação (editável)
              Text(
                'Ocupação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                ..._occupations.map((occupation) => ListTile(
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
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.08),
                        colors.primary.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.briefcase(),
                        color: colors.mediumGray,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
                      PhosphorIcon(
                        PhosphorIcons.caretDown(),
                        color: colors.mediumGray,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Divider(color: colors.lightGray, height: 1),
              const SizedBox(height: 32),

              // INFORMAÇÕES DA CONTA
              Text(
                'INFORMAÇÕES DA CONTA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.mediumGray,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.08),
                      colors.primary.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.calendarCheck(),
                          color: colors.mediumGray,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Membro desde',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.mediumGray,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          user?.createdAt != null
                              ? '${user!.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}'
                              : '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.darkGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colors.lightGray, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.identificationCard(),
                          color: colors.mediumGray,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'ID da Conta',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.mediumGray,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _accountId,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.darkGray,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Botão Salvar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.check(PhosphorIconsStyle.bold),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Salvar Alterações',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedField({
    required AppColors colors,
    required PhosphorIconData icon,
    required String label,
    required String value,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.08),
                colors.primary.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              PhosphorIcon(
                icon,
                color: colors.mediumGray,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.mediumGray,
                  ),
                ),
              ),
              PhosphorIcon(
                PhosphorIcons.lock(),
                color: colors.mediumGray,
                size: 20,
              ),
            ],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: colors.mediumGray,
            ),
          ),
        ],
      ],
    );
  }
}
