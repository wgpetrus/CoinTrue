#!/usr/bin/env dart

/// Script para migrar todas as telas para usar cores adaptáveis do Dark Mode
/// 
/// Este script automatiza a migração de AppConstants.colors para context.colors
/// em todas as telas do projeto.

import 'dart:io';

void main() {
  print('🌙 Iniciando migração para Dark Mode...\n');
  
  // Lista de arquivos para migrar
  final filesToMigrate = [
    'lib/views/screens/crypto/portfolio_screen.dart',
    'lib/views/screens/crypto/notification_settings_screen.dart',
    'lib/views/screens/onboarding/splash_screen.dart',
    'lib/views/screens/onboarding/onboarding_screen.dart',
    'lib/views/screens/onboarding/biometric_setup_screen.dart',
  ];
  
  for (final filePath in filesToMigrate) {
    migrateFile(filePath);
  }
  
  print('\n✅ Migração concluída!');
  print('🧪 Execute "flutter run" para testar o Dark Mode completo.');
}

void migrateFile(String filePath) {
  final file = File(filePath);
  
  if (!file.existsSync()) {
    print('❌ Arquivo não encontrado: $filePath');
    return;
  }
  
  print('🔄 Migrando: $filePath');
  
  String content = file.readAsStringSync();
  
  // 1. Adicionar import do theme_helper se não existir
  if (!content.contains("import '../../../utils/theme_helper.dart';")) {
    content = content.replaceFirst(
      "import '../../../utils/constants.dart';",
      "import '../../../utils/constants.dart';\nimport '../../../utils/theme_helper.dart';",
    );
  }
  
  // 2. Substituir AppConstants.colors por context.colors
  content = content.replaceAll('AppConstants.colors', 'context.colors');
  
  // 3. Substituir cores específicas
  content = content.replaceAll('colors.white', 'colors.background');
  content = content.replaceAll('colors.lightGray', 'colors.surface');
  content = content.replaceAll('colors.darkGray', 'colors.onBackground');
  content = content.replaceAll('colors.mediumGray', 'colors.onSurface');
  content = content.replaceAll('colors.veryLightGray', 'colors.outline');
  
  // Escrever arquivo atualizado
  file.writeAsStringSync(content);
  
  print('✅ Migrado: $filePath');
}