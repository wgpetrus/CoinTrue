// ARQUIVO TEMPORÁRIO - Funcionalidades salvas da HomeScreen antiga
// 
// Este arquivo contém os métodos de logout e excluir conta que estavam
// na HomeScreen antiga. Serão movidos para ProfileScreen na Fase 9.
// 
// NÃO DELETAR até implementar ProfileScreen!

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/theme_helper.dart';

/// Método para fazer logout
/// 
/// Será movido para ProfileScreen na Fase 9
Future<void> handleLogout(BuildContext context, AuthController authController) async {
  final colors = context.colors;
  
  // Confirma logout
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Sair'),
      content: const Text('Tem certeza que deseja sair?'),
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
    await authController.signOut();
    
    if (context.mounted && !authController.isAuthenticated) {
      // Volta para tela de login e remove todas as rotas anteriores
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}

/// Método para excluir conta
/// 
/// Será movido para ProfileScreen na Fase 9
Future<void> handleDeleteAccount(BuildContext context, AuthController authController) async {
  final colors = context.colors;
  final user = authController.currentUser;
  
  if (user == null) return;
  
  // Primeiro confirma a intenção
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.warning(PhosphorIconsStyle.fill),
            size: 28,
            color: colors.error,
          ),
          const SizedBox(width: 12),
          const Text('Excluir Conta'),
        ],
      ),
      content: const Text(
        'Esta ação é irreversível! Todos os seus dados serão permanentemente excluídos.\n\nTem certeza que deseja excluir sua conta?',
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
          child: const Text('Continuar'),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  // Detecta se é conta de email/senha ou OAuth
  final isOAuthAccount = user.provider == AuthProvider.google || user.provider == AuthProvider.apple;
  
  // Verifica se tem biometria ativada
  if (authController.biometricEnabled) {
    // Pede autenticação biométrica
    try {
      final authenticated = await authController.biometricService.authenticate(
        reason: 'Confirme sua identidade para excluir a conta',
      );
      
      if (!authenticated || !context.mounted) return;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Autenticação biométrica falhou'),
            backgroundColor: colors.error,
          ),
        );
      }
      return;
    }
  }

  // Agora exclui a conta
  if (context.mounted) {
    await authController.deleteAccount();
    
    if (context.mounted && !authController.isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conta excluída com sucesso'),
          backgroundColor: colors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (context.mounted && authController.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.error!),
          backgroundColor: colors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

/// Método para desabilitar biometria
/// 
/// Será movido para ProfileScreen na Fase 9
Future<void> handleDisableBiometric(BuildContext context, AuthController authController) async {
  final colors = context.colors;
  
  // Confirma desativação
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Desativar Biometria'),
      content: const Text('Tem certeza que deseja desativar a biometria?'),
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
          child: const Text('Desativar'),
        ),
      ],
    ),
  );

  if (confirm == true && context.mounted) {
    await authController.disableBiometric();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Biometria desativada'),
          backgroundColor: colors.success,
        ),
      );
    }
  }
}
