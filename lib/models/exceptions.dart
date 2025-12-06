/// Base exception class for the authentication system
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType: [$code] $message';
    }
    return '$runtimeType: $message';
  }
}

/// Exception thrown when network connectivity issues occur
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });

  /// Creates a NetworkException for no internet connection
  const NetworkException.noConnection()
      : super(
          'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
          code: 'NO_CONNECTION',
        );

  /// Creates a NetworkException for timeout
  const NetworkException.timeout()
      : super(
          'A requisição excedeu o tempo limite. Tente novamente.',
          code: 'TIMEOUT',
        );

  /// Creates a NetworkException for server error
  const NetworkException.serverError()
      : super(
          'Erro no servidor. Tente novamente mais tarde.',
          code: 'SERVER_ERROR',
        );
}

/// Exception thrown when authentication-related errors occur
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
  });

  /// Creates an AuthException for invalid credentials
  const AuthException.invalidCredentials()
      : super(
          'Credenciais inválidas. Verifique seus dados e tente novamente.',
          code: 'INVALID_CREDENTIALS',
        );

  /// Creates an AuthException for user not found
  const AuthException.userNotFound()
      : super(
          'Usuário não encontrado.',
          code: 'USER_NOT_FOUND',
        );

  /// Creates an AuthException for account disabled
  const AuthException.accountDisabled()
      : super(
          'Esta conta foi desabilitada. Entre em contato com o suporte.',
          code: 'ACCOUNT_DISABLED',
        );

  /// Creates an AuthException for cancelled operation
  const AuthException.cancelled()
      : super(
          'Operação de autenticação cancelada.',
          code: 'CANCELLED',
        );

  /// Creates an AuthException for service unavailable
  const AuthException.serviceUnavailable()
      : super(
          'Serviço de autenticação temporariamente indisponível. Tente novamente mais tarde.',
          code: 'SERVICE_UNAVAILABLE',
        );

  /// Creates an AuthException for too many requests
  const AuthException.tooManyRequests()
      : super(
          'Muitas tentativas de login. Aguarde alguns minutos e tente novamente.',
          code: 'TOO_MANY_REQUESTS',
        );
}

/// Exception thrown when biometric authentication errors occur
class BiometricException extends AppException {
  const BiometricException(
    super.message, {
    super.code,
    super.originalError,
  });

  /// Creates a BiometricException for unavailable biometric
  const BiometricException.notAvailable()
      : super(
          'Biometria não está disponível neste dispositivo.',
          code: 'NOT_AVAILABLE',
        );

  /// Creates a BiometricException for not enrolled
  const BiometricException.notEnrolled()
      : super(
          'Nenhuma biometria configurada no dispositivo. Configure nas configurações do sistema.',
          code: 'NOT_ENROLLED',
        );

  /// Creates a BiometricException for authentication failed
  const BiometricException.authFailed()
      : super(
          'Falha na autenticação biométrica. Tente novamente.',
          code: 'AUTH_FAILED',
        );

  /// Creates a BiometricException for too many attempts
  const BiometricException.tooManyAttempts()
      : super(
          'Muitas tentativas falhadas. Use login manual.',
          code: 'TOO_MANY_ATTEMPTS',
        );

  /// Creates a BiometricException for permission denied
  const BiometricException.permissionDenied()
      : super(
          'Permissão para usar biometria foi negada.',
          code: 'PERMISSION_DENIED',
        );

  /// Creates a BiometricException for cancelled operation
  const BiometricException.cancelled()
      : super(
          'Autenticação biométrica cancelada.',
          code: 'CANCELLED',
        );
}

/// Exception thrown when validation errors occur
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
  });

  /// Creates a ValidationException for invalid email
  const ValidationException.invalidEmail()
      : super(
          'Email em formato inválido.',
          code: 'INVALID_EMAIL',
        );

  /// Creates a ValidationException for empty field
  const ValidationException.emptyField(String fieldName)
      : super(
          'O campo $fieldName é obrigatório.',
          code: 'EMPTY_FIELD',
        );

  /// Creates a ValidationException for invalid format
  const ValidationException.invalidFormat(String fieldName)
      : super(
          'Formato inválido para o campo $fieldName.',
          code: 'INVALID_FORMAT',
        );

  /// Creates a ValidationException for malicious input
  const ValidationException.maliciousInput()
      : super(
          'Entrada contém caracteres não permitidos.',
          code: 'MALICIOUS_INPUT',
        );
}

/// Exception thrown for unexpected errors
class UnexpectedException extends AppException {
  const UnexpectedException([
    String message = 'Ocorreu um erro inesperado. Tente novamente.',
    dynamic originalError,
  ]) : super(
          message,
          code: 'UNEXPECTED',
          originalError: originalError,
        );
}
