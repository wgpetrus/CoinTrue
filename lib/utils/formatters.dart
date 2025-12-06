import 'package:flutter/services.dart';

/// Formatadores de texto para campos de entrada
/// 
/// Fornece máscaras de formatação automática para CPF, telefone e data.

/// Formatador de CPF: 000.000.000-00
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove tudo que não é número
    final numbers = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 11 dígitos
    if (numbers.length > 11) {
      return oldValue;
    }
    
    // Aplica a máscara
    String formatted = '';
    for (int i = 0; i < numbers.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      } else if (i == 9) {
        formatted += '-';
      }
      formatted += numbers[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de Telefone: (00) 00000-0000 ou (00) 0000-0000
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove tudo que não é número
    final numbers = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 11 dígitos
    if (numbers.length > 11) {
      return oldValue;
    }
    
    // Aplica a máscara
    String formatted = '';
    for (int i = 0; i < numbers.length; i++) {
      if (i == 0) {
        formatted += '(';
      } else if (i == 2) {
        formatted += ') ';
      } else if (numbers.length <= 10 && i == 6) {
        // Telefone fixo: (00) 0000-0000
        formatted += '-';
      } else if (numbers.length == 11 && i == 7) {
        // Celular: (00) 00000-0000
        formatted += '-';
      }
      formatted += numbers[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de Data: DD/MM/AAAA
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove tudo que não é número
    final numbers = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 8 dígitos
    if (numbers.length > 8) {
      return oldValue;
    }
    
    // Aplica a máscara
    String formatted = '';
    for (int i = 0; i < numbers.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += numbers[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Validadores de campos

class Validators {
  /// Valida CPF (apenas formato, não valida dígitos verificadores)
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Verifica se todos os dígitos são iguais (CPF inválido)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) {
      return 'CPF inválido';
    }
    
    return null;
  }
  
  /// Valida telefone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length < 10 || numbers.length > 11) {
      return 'Telefone inválido';
    }
    
    return null;
  }
  
  /// Valida data de nascimento
  static String? birthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }
    
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Formato inválido (DD/MM/AAAA)';
    }
    
    // Valida se é uma data válida
    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      if (day < 1 || day > 31) {
        return 'Dia inválido';
      }
      
      if (month < 1 || month > 12) {
        return 'Mês inválido';
      }
      
      if (year < 1900 || year > DateTime.now().year) {
        return 'Ano inválido';
      }
      
      // Verifica se a data é válida
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Data inválida';
      }
      
      // Verifica se tem pelo menos 18 anos
      final now = DateTime.now();
      final age = now.year - year;
      if (age < 18 || (age == 18 && now.month < month) || 
          (age == 18 && now.month == month && now.day < day)) {
        return 'Você deve ter pelo menos 18 anos';
      }
      
      return null;
    } catch (e) {
      return 'Data inválida';
    }
  }
  
  /// Valida nome (não vazio e com pelo menos 2 caracteres)
  static String? name(String? value, {String fieldName = 'Nome'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName deve ter pelo menos 2 caracteres';
    }
    
    return null;
  }
}
