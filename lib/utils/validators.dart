/// Classe utilitária para validação de entradas do usuário
/// Implementa validações de formato, campos obrigatórios e sanitização
class Validators {
  // Previne instanciação
  Validators._();

  /// Regex para validação de email
  /// Aceita formatos padrão de email: usuario@dominio.com
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Regex para detectar caracteres potencialmente maliciosos
  /// Detecta: <, >, &, ", ', /, \, ;, script tags, etc.
  static final RegExp _maliciousCharsRegex = RegExp(
    r'''[<>&"'/\\;]|script|javascript|onerror|onclick''',
    caseSensitive: false,
  );

  /// Valida se o email está em formato válido
  /// 
  /// Retorna `true` se o email é válido, `false` caso contrário
  /// 
  /// Exemplos:
  /// ```dart
  /// Validators.isValidEmail('user@example.com'); // true
  /// Validators.isValidEmail('invalid'); // false
  /// Validators.isValidEmail(''); // false
  /// ```
  /// 
  /// Requisitos: 4.1, 4.3
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    return _emailRegex.hasMatch(email.trim());
  }

  /// Verifica se o campo não está vazio
  /// 
  /// Retorna `true` se o campo contém texto (após trim), `false` caso contrário
  /// 
  /// Exemplos:
  /// ```dart
  /// Validators.isNotEmpty('texto'); // true
  /// Validators.isNotEmpty('   '); // false
  /// Validators.isNotEmpty(''); // false
  /// Validators.isNotEmpty(null); // false
  /// ```
  /// 
  /// Requisitos: 4.1, 4.4
  static bool isNotEmpty(String? value) {
    if (value == null) {
      return false;
    }
    return value.trim().isNotEmpty;
  }

  /// Sanitiza entrada removendo caracteres potencialmente maliciosos
  /// 
  /// Remove ou escapa caracteres que podem ser usados em ataques de injeção
  /// como: <, >, &, ", ', /, \, ;, e palavras-chave como 'script'
  /// 
  /// Retorna a string sanitizada ou string vazia se entrada for null
  /// 
  /// Exemplos:
  /// ```dart
  /// Validators.sanitizeInput('normal text'); // 'normal text'
  /// Validators.sanitizeInput('<script>alert("xss")</script>'); // 'alertxss'
  /// Validators.sanitizeInput('user@example.com'); // 'userexample.com'
  /// ```
  /// 
  /// Requisitos: 4.1, 4.5
  static String sanitizeInput(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }
    
    // Remove caracteres maliciosos
    String sanitized = input.replaceAll(_maliciousCharsRegex, '');
    
    // Remove espaços extras
    sanitized = sanitized.trim();
    
    return sanitized;
  }

  /// Valida senha (implementação futura)
  /// 
  /// Critérios planejados:
  /// - Mínimo 8 caracteres
  /// - Pelo menos uma letra maiúscula
  /// - Pelo menos uma letra minúscula
  /// - Pelo menos um número
  /// - Pelo menos um caractere especial
  /// 
  /// Atualmente retorna sempre `true` pois não há login com senha implementado
  /// 
  /// Requisitos: 4.1 (futuro)
  static bool validatePassword(String? password) {
    // TODO: Implementar quando login com senha for adicionado
    // Por enquanto, retorna true pois não usamos senha
    return true;
  }

  /// Valida múltiplos campos obrigatórios de uma vez
  /// 
  /// Retorna `true` se todos os campos são não-vazios, `false` caso contrário
  /// 
  /// Exemplos:
  /// ```dart
  /// Validators.validateRequiredFields(['nome', 'email']); // true
  /// Validators.validateRequiredFields(['nome', '']); // false
  /// ```
  static bool validateRequiredFields(List<String?> fields) {
    return fields.every((field) => isNotEmpty(field));
  }
}
