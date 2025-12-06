import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper para flutter_secure_storage
/// Encapsula operações de armazenamento seguro com tratamento de erros
/// 
/// Usa criptografia AES-256 para proteger dados sensíveis:
/// - iOS: Keychain
/// - Android: KeyStore
/// 
/// Requisitos: 6.1, 6.3
class SecureStorage {
  final FlutterSecureStorage _storage;

  /// Construtor com injeção de dependência para facilitar testes
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// Escreve um valor no armazenamento seguro
  /// 
  /// [key] - Chave para identificar o valor
  /// [value] - Valor a ser armazenado
  /// 
  /// Lança [SecureStorageException] se a operação falhar
  /// 
  /// Exemplos:
  /// ```dart
  /// await secureStorage.write(key: 'token', value: 'abc123');
  /// await secureStorage.write(key: 'userId', value: 'user_123');
  /// ```
  Future<void> write({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException(
        'Falha ao escrever no armazenamento seguro: $e',
      );
    }
  }

  /// Lê um valor do armazenamento seguro
  /// 
  /// [key] - Chave do valor a ser lido
  /// 
  /// Retorna o valor armazenado ou `null` se não existir
  /// 
  /// Lança [SecureStorageException] se a operação falhar
  /// 
  /// Exemplos:
  /// ```dart
  /// final token = await secureStorage.read(key: 'token');
  /// final userId = await secureStorage.read(key: 'userId');
  /// ```
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Falha ao ler do armazenamento seguro: $e',
      );
    }
  }

  /// Deleta um valor específico do armazenamento seguro
  /// 
  /// [key] - Chave do valor a ser deletado
  /// 
  /// Lança [SecureStorageException] se a operação falhar
  /// 
  /// Exemplos:
  /// ```dart
  /// await secureStorage.delete(key: 'token');
  /// await secureStorage.delete(key: 'userId');
  /// ```
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Falha ao deletar do armazenamento seguro: $e',
      );
    }
  }

  /// Deleta todos os valores do armazenamento seguro
  /// 
  /// Útil para logout completo ou reset da aplicação
  /// 
  /// Lança [SecureStorageException] se a operação falhar
  /// 
  /// Exemplos:
  /// ```dart
  /// await secureStorage.deleteAll(); // Limpa tudo no logout
  /// ```
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException(
        'Falha ao deletar todos os dados do armazenamento seguro: $e',
      );
    }
  }

  /// Verifica se uma chave existe no armazenamento
  /// 
  /// [key] - Chave a ser verificada
  /// 
  /// Retorna `true` se a chave existe, `false` caso contrário
  /// 
  /// Lança [SecureStorageException] se a operação falhar
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Falha ao verificar chave no armazenamento seguro: $e',
      );
    }
  }

  /// Retorna todas as chaves armazenadas
  /// 
  /// Útil para debug ou migração de dados
  /// 
  /// Lança [SecureStorageException] se a operação falhar
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw SecureStorageException(
        'Falha ao ler todos os dados do armazenamento seguro: $e',
      );
    }
  }
}

/// Exceção customizada para erros de armazenamento seguro
class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}
