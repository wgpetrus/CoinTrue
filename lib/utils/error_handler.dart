import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/exceptions.dart';
import 'constants.dart';
import 'rate_limiter.dart';

/// Níveis de severidade para logging de erros
enum ErrorSeverity {
  /// Erro informativo - não afeta funcionalidade
  info,

  /// Aviso - pode afetar funcionalidade mas não é crítico
  warning,

  /// Erro - afeta funcionalidade mas é recuperável
  error,

  /// Crítico - afeta funcionalidade de forma grave
  critical,
}

/// Resultado do tratamento de erro
class ErrorResult {
  /// Mensagem amigável para exibir ao usuário
  final String userMessage;

  /// Código do erro (para tracking)
  final String? errorCode;

  /// Nível de severidade
  final ErrorSeverity severity;

  /// Se deve permitir retry
  final bool allowRetry;

  const ErrorResult({
    required this.userMessage,
    this.errorCode,
    required this.severity,
    this.allowRetry = true,
  });
}

/// Utilitário para tratamento centralizado de erros
/// 
/// Responsável por:
/// - Mapear exceções para mensagens de usuário
/// - Fazer logging seguro de erros (sem dados sensíveis)
/// - Classificar erros por severidade
class ErrorHandler {
  // Previne instanciação
  ErrorHandler._();

  /// Trata uma exceção e retorna resultado formatado
  /// 
  /// [error] - A exceção a ser tratada
  /// [stackTrace] - Stack trace opcional para logging
  /// [context] - Contexto adicional para logging (ex: "login", "biometric_setup")
  /// 
  /// Retorna [ErrorResult] com mensagem amigável e metadados
  static ErrorResult handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    // Log do erro (sem dados sensíveis)
    _logError(error, stackTrace: stackTrace, context: context);

    // Mapeia exceção para resultado
    if (error is RateLimitExceededException) {
      return _handleRateLimitException(error);
    } else if (error is NetworkException) {
      return _handleNetworkException(error);
    } else if (error is AuthException) {
      return _handleAuthException(error);
    } else if (error is BiometricException) {
      return _handleBiometricException(error);
    } else if (error is ValidationException) {
      return _handleValidationException(error);
    } else if (error is UnexpectedException) {
      return _handleUnexpectedException(error);
    } else {
      // Erro desconhecido
      return _handleUnknownError(error);
    }
  }

  /// Trata exceções de rate limiting
  static ErrorResult _handleRateLimitException(RateLimitExceededException error) {
    return ErrorResult(
      userMessage: error.getUserMessage(),
      errorCode: 'RATE_LIMIT_EXCEEDED',
      severity: ErrorSeverity.warning,
      allowRetry: false, // Não permitir retry imediato
    );
  }

  /// Trata exceções de rede
  static ErrorResult _handleNetworkException(NetworkException error) {
    String message;
    ErrorSeverity severity;

    switch (error.code) {
      case 'NO_CONNECTION':
        message = AppConstants.strings.errorNetwork;
        severity = ErrorSeverity.warning;
        break;
      case 'TIMEOUT':
        message = AppConstants.strings.errorTimeout;
        severity = ErrorSeverity.warning;
        break;
      case 'SERVER_ERROR':
        message = AppConstants.strings.errorServiceUnavailable;
        severity = ErrorSeverity.error;
        break;
      default:
        message = error.message;
        severity = ErrorSeverity.error;
    }

    return ErrorResult(
      userMessage: message,
      errorCode: error.code,
      severity: severity,
      allowRetry: true,
    );
  }

  /// Trata exceções de autenticação
  static ErrorResult _handleAuthException(AuthException error) {
    String message;
    ErrorSeverity severity;
    bool allowRetry;

    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        message = AppConstants.strings.errorInvalidCredentials;
        severity = ErrorSeverity.warning;
        allowRetry = true;
        break;
      case 'USER_NOT_FOUND':
        // Mensagem genérica por segurança (não revelar se usuário existe)
        message = AppConstants.strings.errorInvalidCredentials;
        severity = ErrorSeverity.warning;
        allowRetry = true;
        break;
      case 'ACCOUNT_DISABLED':
        message = error.message;
        severity = ErrorSeverity.critical;
        allowRetry = false;
        break;
      case 'CANCELLED':
        message = error.message;
        severity = ErrorSeverity.info;
        allowRetry = true;
        break;
      case 'SERVICE_UNAVAILABLE':
        message = AppConstants.strings.errorServiceUnavailable;
        severity = ErrorSeverity.error;
        allowRetry = true;
        break;
      case 'TOO_MANY_REQUESTS':
        message = error.message;
        severity = ErrorSeverity.warning;
        allowRetry = false; // Não permitir retry imediato
        break;
      default:
        message = error.message;
        severity = ErrorSeverity.error;
        allowRetry = true;
    }

    return ErrorResult(
      userMessage: message,
      errorCode: error.code,
      severity: severity,
      allowRetry: allowRetry,
    );
  }

  /// Trata exceções de biometria
  static ErrorResult _handleBiometricException(BiometricException error) {
    String message;
    ErrorSeverity severity;
    bool allowRetry;

    switch (error.code) {
      case 'NOT_AVAILABLE':
        message = AppConstants.strings.errorBiometricNotAvailable;
        severity = ErrorSeverity.info;
        allowRetry = false;
        break;
      case 'NOT_ENROLLED':
        message = AppConstants.strings.errorBiometricNotEnrolled;
        severity = ErrorSeverity.info;
        allowRetry = false;
        break;
      case 'AUTH_FAILED':
        message = AppConstants.strings.errorBiometricFailed;
        severity = ErrorSeverity.warning;
        allowRetry = true;
        break;
      case 'TOO_MANY_ATTEMPTS':
        message = AppConstants.strings.errorBiometricMaxAttempts;
        severity = ErrorSeverity.warning;
        allowRetry = false;
        break;
      case 'PERMISSION_DENIED':
        message = error.message;
        severity = ErrorSeverity.warning;
        allowRetry = false;
        break;
      case 'CANCELLED':
        message = error.message;
        severity = ErrorSeverity.info;
        allowRetry = true;
        break;
      default:
        message = error.message;
        severity = ErrorSeverity.error;
        allowRetry = true;
    }

    return ErrorResult(
      userMessage: message,
      errorCode: error.code,
      severity: severity,
      allowRetry: allowRetry,
    );
  }

  /// Trata exceções de validação
  static ErrorResult _handleValidationException(ValidationException error) {
    String message;

    switch (error.code) {
      case 'INVALID_EMAIL':
        message = AppConstants.strings.errorInvalidEmail;
        break;
      case 'EMPTY_FIELD':
        message = error.message;
        break;
      case 'INVALID_FORMAT':
        message = error.message;
        break;
      case 'MALICIOUS_INPUT':
        message = error.message;
        break;
      default:
        message = error.message;
    }

    return ErrorResult(
      userMessage: message,
      errorCode: error.code,
      severity: ErrorSeverity.warning,
      allowRetry: true,
    );
  }

  /// Trata exceções inesperadas
  static ErrorResult _handleUnexpectedException(UnexpectedException error) {
    return ErrorResult(
      userMessage: AppConstants.strings.errorGeneric,
      errorCode: error.code,
      severity: ErrorSeverity.error,
      allowRetry: true,
    );
  }

  /// Trata erros desconhecidos
  static ErrorResult _handleUnknownError(dynamic error) {
    return ErrorResult(
      userMessage: AppConstants.strings.errorGeneric,
      errorCode: 'UNKNOWN',
      severity: ErrorSeverity.error,
      allowRetry: true,
    );
  }

  /// Faz logging seguro do erro
  /// 
  /// IMPORTANTE: Nunca registra dados sensíveis como:
  /// - Senhas
  /// - Tokens completos
  /// - Dados biométricos
  /// - Informações pessoais identificáveis
  static void _logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    // Determina severidade para o log
    final severity = _getSeverityForLog(error);

    // Monta mensagem de log
    final logMessage = _buildLogMessage(error, context);

    // Faz log baseado na severidade
    switch (severity) {
      case ErrorSeverity.info:
        developer.log(
          logMessage,
          name: 'ErrorHandler',
          level: 800, // INFO
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case ErrorSeverity.warning:
        developer.log(
          logMessage,
          name: 'ErrorHandler',
          level: 900, // WARNING
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case ErrorSeverity.error:
        developer.log(
          logMessage,
          name: 'ErrorHandler',
          level: 1000, // SEVERE
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case ErrorSeverity.critical:
        developer.log(
          logMessage,
          name: 'ErrorHandler',
          level: 1200, // SHOUT
          error: error,
          stackTrace: stackTrace,
        );
        break;
    }

    // Em modo debug, também imprime no console
    if (kDebugMode) {
      debugPrint('[$severity] $logMessage');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Determina severidade para logging
  static ErrorSeverity _getSeverityForLog(dynamic error) {
    if (error is AppException) {
      switch (error.code) {
        case 'CANCELLED':
          return ErrorSeverity.info;
        case 'NOT_AVAILABLE':
        case 'NOT_ENROLLED':
        case 'PERMISSION_DENIED':
          return ErrorSeverity.info;
        case 'NO_CONNECTION':
        case 'TIMEOUT':
        case 'INVALID_CREDENTIALS':
        case 'AUTH_FAILED':
        case 'TOO_MANY_ATTEMPTS':
          return ErrorSeverity.warning;
        case 'ACCOUNT_DISABLED':
          return ErrorSeverity.critical;
        default:
          return ErrorSeverity.error;
      }
    }
    return ErrorSeverity.error;
  }

  /// Constrói mensagem de log segura
  static String _buildLogMessage(dynamic error, String? context) {
    final buffer = StringBuffer();

    // Adiciona contexto se disponível
    if (context != null && context.isNotEmpty) {
      buffer.write('[$context] ');
    }

    // Adiciona tipo do erro
    buffer.write('${error.runtimeType}: ');

    // Adiciona mensagem do erro (já sanitizada nas exceções)
    if (error is AppException) {
      if (error.code != null) {
        buffer.write('[${error.code}] ');
      }
      buffer.write(error.message);
    } else {
      buffer.write(error.toString());
    }

    return buffer.toString();
  }

  /// Obtém mensagem amigável para um erro
  /// 
  /// Método de conveniência que retorna apenas a mensagem
  static String getUserMessage(dynamic error) {
    return handleError(error).userMessage;
  }

  /// Verifica se um erro permite retry
  static bool canRetry(dynamic error) {
    return handleError(error).allowRetry;
  }

  /// Obtém severidade de um erro
  static ErrorSeverity getSeverity(dynamic error) {
    return handleError(error).severity;
  }
}
