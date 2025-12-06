import 'package:flutter_test/flutter_test.dart';
import 'package:login/models/exceptions.dart';
import 'package:login/utils/error_handler.dart';
import 'package:login/utils/constants.dart';
import 'package:login/utils/rate_limiter.dart';

void main() {
  group('ErrorHandler - NetworkException', () {
    test('deve mapear NetworkException.noConnection corretamente', () {
      // Arrange
      const exception = NetworkException.noConnection();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorNetwork);
      expect(result.errorCode, 'NO_CONNECTION');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear NetworkException.timeout corretamente', () {
      // Arrange
      const exception = NetworkException.timeout();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorTimeout);
      expect(result.errorCode, 'TIMEOUT');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear NetworkException.serverError corretamente', () {
      // Arrange
      const exception = NetworkException.serverError();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorServiceUnavailable);
      expect(result.errorCode, 'SERVER_ERROR');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });

    test('deve mapear NetworkException customizada corretamente', () {
      // Arrange
      const exception = NetworkException(
        'Erro de rede customizado',
        code: 'CUSTOM_ERROR',
      );

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, 'Erro de rede customizado');
      expect(result.errorCode, 'CUSTOM_ERROR');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });
  });

  group('ErrorHandler - AuthException', () {
    test('deve mapear AuthException.invalidCredentials corretamente', () {
      // Arrange
      const exception = AuthException.invalidCredentials();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorInvalidCredentials);
      expect(result.errorCode, 'INVALID_CREDENTIALS');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear AuthException.userNotFound com mensagem genérica por segurança', () {
      // Arrange
      const exception = AuthException.userNotFound();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      // Deve usar mensagem genérica para não revelar se usuário existe
      expect(result.userMessage, AppConstants.strings.errorInvalidCredentials);
      expect(result.errorCode, 'USER_NOT_FOUND');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear AuthException.accountDisabled corretamente', () {
      // Arrange
      const exception = AuthException.accountDisabled();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'ACCOUNT_DISABLED');
      expect(result.severity, ErrorSeverity.critical);
      expect(result.allowRetry, false);
    });

    test('deve mapear AuthException.cancelled corretamente', () {
      // Arrange
      const exception = AuthException.cancelled();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'CANCELLED');
      expect(result.severity, ErrorSeverity.info);
      expect(result.allowRetry, true);
    });

    test('deve mapear AuthException.serviceUnavailable corretamente', () {
      // Arrange
      const exception = AuthException.serviceUnavailable();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorServiceUnavailable);
      expect(result.errorCode, 'SERVICE_UNAVAILABLE');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });

    test('deve mapear AuthException.tooManyRequests corretamente', () {
      // Arrange
      const exception = AuthException.tooManyRequests();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'TOO_MANY_REQUESTS');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, false);
    });

    test('deve mapear AuthException customizada corretamente', () {
      // Arrange
      const exception = AuthException(
        'Erro de autenticação customizado',
        code: 'CUSTOM_AUTH_ERROR',
      );

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, 'Erro de autenticação customizado');
      expect(result.errorCode, 'CUSTOM_AUTH_ERROR');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });
  });

  group('ErrorHandler - BiometricException', () {
    test('deve mapear BiometricException.notAvailable corretamente', () {
      // Arrange
      const exception = BiometricException.notAvailable();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorBiometricNotAvailable);
      expect(result.errorCode, 'NOT_AVAILABLE');
      expect(result.severity, ErrorSeverity.info);
      expect(result.allowRetry, false);
    });

    test('deve mapear BiometricException.notEnrolled corretamente', () {
      // Arrange
      const exception = BiometricException.notEnrolled();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorBiometricNotEnrolled);
      expect(result.errorCode, 'NOT_ENROLLED');
      expect(result.severity, ErrorSeverity.info);
      expect(result.allowRetry, false);
    });

    test('deve mapear BiometricException.authFailed corretamente', () {
      // Arrange
      const exception = BiometricException.authFailed();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorBiometricFailed);
      expect(result.errorCode, 'AUTH_FAILED');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear BiometricException.tooManyAttempts corretamente', () {
      // Arrange
      const exception = BiometricException.tooManyAttempts();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorBiometricMaxAttempts);
      expect(result.errorCode, 'TOO_MANY_ATTEMPTS');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, false);
    });

    test('deve mapear BiometricException.permissionDenied corretamente', () {
      // Arrange
      const exception = BiometricException.permissionDenied();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'PERMISSION_DENIED');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, false);
    });

    test('deve mapear BiometricException.cancelled corretamente', () {
      // Arrange
      const exception = BiometricException.cancelled();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'CANCELLED');
      expect(result.severity, ErrorSeverity.info);
      expect(result.allowRetry, true);
    });

    test('deve mapear BiometricException customizada corretamente', () {
      // Arrange
      const exception = BiometricException(
        'Erro biométrico customizado',
        code: 'CUSTOM_BIO_ERROR',
      );

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, 'Erro biométrico customizado');
      expect(result.errorCode, 'CUSTOM_BIO_ERROR');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });
  });

  group('ErrorHandler - ValidationException', () {
    test('deve mapear ValidationException.invalidEmail corretamente', () {
      // Arrange
      const exception = ValidationException.invalidEmail();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorInvalidEmail);
      expect(result.errorCode, 'INVALID_EMAIL');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear ValidationException.emptyField corretamente', () {
      // Arrange
      const exception = ValidationException.emptyField('email');

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'EMPTY_FIELD');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear ValidationException.invalidFormat corretamente', () {
      // Arrange
      const exception = ValidationException.invalidFormat('telefone');

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'INVALID_FORMAT');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear ValidationException.maliciousInput corretamente', () {
      // Arrange
      const exception = ValidationException.maliciousInput();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.message);
      expect(result.errorCode, 'MALICIOUS_INPUT');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });

    test('deve mapear ValidationException customizada corretamente', () {
      // Arrange
      const exception = ValidationException(
        'Erro de validação customizado',
        code: 'CUSTOM_VALIDATION',
      );

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, 'Erro de validação customizado');
      expect(result.errorCode, 'CUSTOM_VALIDATION');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, true);
    });
  });

  group('ErrorHandler - UnexpectedException', () {
    test('deve mapear UnexpectedException corretamente', () {
      // Arrange
      const exception = UnexpectedException();

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorGeneric);
      expect(result.errorCode, 'UNEXPECTED');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });

    test('deve mapear UnexpectedException com mensagem customizada', () {
      // Arrange
      const exception = UnexpectedException('Erro inesperado customizado');

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorGeneric);
      expect(result.errorCode, 'UNEXPECTED');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });
  });

  group('ErrorHandler - RateLimitExceededException', () {
    test('deve mapear RateLimitExceededException corretamente', () {
      // Arrange
      const exception = RateLimitExceededException(
        'Muitas tentativas',
        Duration(seconds: 30),
      );

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, exception.getUserMessage());
      expect(result.errorCode, 'RATE_LIMIT_EXCEEDED');
      expect(result.severity, ErrorSeverity.warning);
      expect(result.allowRetry, false);
    });
  });

  group('ErrorHandler - Exceções Genéricas', () {
    test('deve mapear exceção desconhecida corretamente', () {
      // Arrange
      final exception = Exception('Erro genérico do Dart');

      // Act
      final result = ErrorHandler.handleError(exception);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorGeneric);
      expect(result.errorCode, 'UNKNOWN');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });

    test('deve mapear erro genérico (não Exception) corretamente', () {
      // Arrange
      const error = 'String de erro';

      // Act
      final result = ErrorHandler.handleError(error);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorGeneric);
      expect(result.errorCode, 'UNKNOWN');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });

    test('deve mapear Error genérico corretamente', () {
      // Arrange
      final error = ArgumentError('Argumento inválido');

      // Act
      final result = ErrorHandler.handleError(error);

      // Assert
      expect(result.userMessage, AppConstants.strings.errorGeneric);
      expect(result.errorCode, 'UNKNOWN');
      expect(result.severity, ErrorSeverity.error);
      expect(result.allowRetry, true);
    });
  });

  group('ErrorHandler - Métodos de Conveniência', () {
    test('getUserMessage deve retornar apenas a mensagem', () {
      // Arrange
      const exception = NetworkException.noConnection();

      // Act
      final message = ErrorHandler.getUserMessage(exception);

      // Assert
      expect(message, AppConstants.strings.errorNetwork);
    });

    test('canRetry deve retornar se permite retry', () {
      // Arrange
      const exceptionWithRetry = NetworkException.timeout();
      const exceptionWithoutRetry = BiometricException.notAvailable();

      // Act
      final canRetry1 = ErrorHandler.canRetry(exceptionWithRetry);
      final canRetry2 = ErrorHandler.canRetry(exceptionWithoutRetry);

      // Assert
      expect(canRetry1, true);
      expect(canRetry2, false);
    });

    test('getSeverity deve retornar a severidade correta', () {
      // Arrange
      const infoException = BiometricException.cancelled();
      const warningException = NetworkException.timeout();
      const errorException = NetworkException.serverError();
      const criticalException = AuthException.accountDisabled();

      // Act
      final severity1 = ErrorHandler.getSeverity(infoException);
      final severity2 = ErrorHandler.getSeverity(warningException);
      final severity3 = ErrorHandler.getSeverity(errorException);
      final severity4 = ErrorHandler.getSeverity(criticalException);

      // Assert
      expect(severity1, ErrorSeverity.info);
      expect(severity2, ErrorSeverity.warning);
      expect(severity3, ErrorSeverity.error);
      expect(severity4, ErrorSeverity.critical);
    });
  });

  group('ErrorHandler - Contexto e Logging', () {
    test('deve aceitar contexto opcional sem quebrar', () {
      // Arrange
      const exception = NetworkException.noConnection();

      // Act & Assert - não deve lançar exceção
      expect(
        () => ErrorHandler.handleError(exception, context: 'login'),
        returnsNormally,
      );
    });

    test('deve aceitar stackTrace opcional sem quebrar', () {
      // Arrange
      const exception = NetworkException.noConnection();
      final stackTrace = StackTrace.current;

      // Act & Assert - não deve lançar exceção
      expect(
        () => ErrorHandler.handleError(exception, stackTrace: stackTrace),
        returnsNormally,
      );
    });

    test('deve aceitar contexto e stackTrace juntos', () {
      // Arrange
      const exception = NetworkException.noConnection();
      final stackTrace = StackTrace.current;

      // Act & Assert - não deve lançar exceção
      expect(
        () => ErrorHandler.handleError(
          exception,
          context: 'biometric_setup',
          stackTrace: stackTrace,
        ),
        returnsNormally,
      );
    });
  });
}
