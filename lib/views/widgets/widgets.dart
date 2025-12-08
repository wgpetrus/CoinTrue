// Barrel file para widgets reutilizáveis
// 
// Exporta todos os widgets customizados organizados por categoria
// para facilitar importações em outros arquivos.
library;

// Common widgets (genéricos e reutilizáveis)
export 'common/social_login_button.dart';
export 'common/loading_overlay.dart';
export 'common/error_message.dart';
export 'common/theme_toggle.dart';

// Auth widgets (específicos de autenticação)
export 'auth/biometric_prompt.dart';

// Crypto widgets (específicos de crypto)
export 'crypto/crypto_icon.dart';
export 'crypto/crypto_list_item.dart';
export 'crypto/crypto_selector_sheet.dart';

// Profile widgets (específicos de perfil)
export 'profile/profile_settings_item.dart';
export 'profile/profile_settings_toggle.dart';
