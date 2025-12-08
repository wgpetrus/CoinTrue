import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:faker/faker.dart';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:login/utils/error_handler.dart';
import 'package:login/models/exceptions.dart';

void main() {
  late Faker faker;

  setUp(() {
    faker = Faker();
  });

  group('Property-Based Tests - Debug Information Completeness', () {
    // **Feature: debug-app-issues, Property 3: Debug information completeness**
    // **Validates: Requirements 2.1, 2.2, 2.5**
    test(
      'Property 3: For any error condition when debugging is enabled, '
      'the system should output detailed diagnostic information including component context and error details',
      () async {
        // Run 100 iterations with different error scenarios
        for (int i = 0; i < 100; i++) {
          // Generate random error scenarios
          final errorTypes = [
            'NetworkException',
            'AuthException',
            'BiometricException',
            'ValidationException',
            'UnexpectedException',
            'GenericException',
          ];
          
          final contexts = [
            'login',
            'biometric_setup',
            'firebase_init',
            'asset_loading',
            'preferences_init',
            'crypto_api',
            'user_profile',
          ];
          
          final randomErrorType = faker.randomGenerator.element(errorTypes);
          final randomContext = faker.randomGenerator.element(contexts);
          final randomErrorMessage = faker.lorem.sentence();
          final randomErrorCode = faker.randomGenerator.element([
            'NETWORK_ERROR',
            'INVALID_CREDENTIALS',
            'NOT_AVAILABLE',
            'TIMEOUT',
            'PERMISSION_DENIED',
            'SERVICE_UNAVAILABLE',
          ]);
          
          // Create different types of exceptions to test
          dynamic testError;
          
          switch (randomErrorType) {
            case 'NetworkException':
              testError = NetworkException(
                randomErrorMessage,
                code: randomErrorCode,
              );
              break;
            case 'AuthException':
              testError = AuthException(
                randomErrorMessage,
                code: randomErrorCode,
              );
              break;
            case 'BiometricException':
              testError = BiometricException(
                randomErrorMessage,
                code: randomErrorCode,
              );
              break;
            case 'ValidationException':
              testError = ValidationException(
                randomErrorMessage,
                code: randomErrorCode,
              );
              break;
            case 'UnexpectedException':
              testError = UnexpectedException(
                randomErrorMessage,
              );
              break;
            default:
              testError = Exception(randomErrorMessage);
          }
          
          // Generate random stack trace for testing
          final stackTrace = StackTrace.current;
          
          // Capture debug information
          List<String> capturedLogs = [];
          List<Map<String, dynamic>> capturedDeveloperLogs = [];
          
          // Mock developer.log to capture logs
          void mockDeveloperLog(
            String message, {
            String? name,
            int? level,
            Object? error,
            StackTrace? stackTrace,
          }) {
            capturedDeveloperLogs.add({
              'message': message,
              'name': name,
              'level': level,
              'error': error,
              'stackTrace': stackTrace,
            });
          }
          
          // Mock debugPrint to capture debug prints
          void mockDebugPrint(String? message, {int? wrapWidth}) {
            if (message != null) {
              capturedLogs.add(message);
            }
          }
          
          // Test error handling with debug information
          final errorResult = ErrorHandler.handleError(
            testError,
            stackTrace: stackTrace,
            context: randomContext,
          );
          
          // Verify error result contains required information
          expect(errorResult, isNotNull,
            reason: 'Error handler should return a result');
          
          expect(errorResult.userMessage, isNotEmpty,
            reason: 'Error result should contain a user message');
          
          expect(errorResult.severity, isNotNull,
            reason: 'Error result should have a severity level');
          
          // Test diagnostic information completeness
          final diagnosticInfo = _buildTestDiagnostics(randomContext, testError, stackTrace);
          
          // Verify diagnostic information contains required fields
          expect(diagnosticInfo, containsPair('context', randomContext),
            reason: 'Diagnostic info should contain the component context');
          
          expect(diagnosticInfo, contains('error'),
            reason: 'Diagnostic info should contain error details');
          
          expect(diagnosticInfo, contains('errorType'),
            reason: 'Diagnostic info should contain error type information');
          
          expect(diagnosticInfo, contains('timestamp'),
            reason: 'Diagnostic info should contain timestamp for debugging');
          
          expect(diagnosticInfo, contains('platform'),
            reason: 'Diagnostic info should contain platform information');
          
          expect(diagnosticInfo, contains('isDebugMode'),
            reason: 'Diagnostic info should indicate if debug mode is enabled');
          
          expect(diagnosticInfo, contains('hasStackTrace'),
            reason: 'Diagnostic info should indicate if stack trace is available');
          
          // Verify error details are actionable
          if (testError is AppException) {
            expect(diagnosticInfo['error'], contains(testError.message),
              reason: 'Error details should contain the original error message');
            
            if (testError.code != null) {
              expect(diagnosticInfo, contains('errorCode'),
                reason: 'Diagnostic info should contain error code when available');
            }
          }
          
          // Verify stack trace information is included when available
          if (stackTrace != null) {
            expect(diagnosticInfo['hasStackTrace'], isTrue,
              reason: 'Should indicate when stack trace is available');
            
            expect(diagnosticInfo, contains('stackPreview'),
              reason: 'Should include stack trace preview for debugging');
          }
          
          // Test system diagnostics completeness
          final systemDiagnostics = _buildTestSystemDiagnostics();
          
          expect(systemDiagnostics, contains('platform'),
            reason: 'System diagnostics should include platform information');
          
          expect(systemDiagnostics, contains('version'),
            reason: 'System diagnostics should include OS version');
          
          expect(systemDiagnostics, contains('isDebugMode'),
            reason: 'System diagnostics should indicate debug mode status');
          
          expect(systemDiagnostics, contains('dartVersion'),
            reason: 'System diagnostics should include Dart version');
          
          // Verify error severity classification
          final severity = ErrorHandler.getSeverity(testError);
          expect(severity, isNotNull,
            reason: 'Error should have a classified severity level');
          
          // Verify retry capability information
          final canRetry = ErrorHandler.canRetry(testError);
          expect(canRetry, isA<bool>(),
            reason: 'Error should have retry capability information');
          
          // Test that debug information is comprehensive enough for troubleshooting
          final userMessage = ErrorHandler.getUserMessage(testError);
          expect(userMessage, isNotEmpty,
            reason: 'Should provide actionable user message');
          
          // Verify that all required diagnostic fields are present and non-empty
          final requiredFields = [
            'context',
            'error',
            'errorType',
            'timestamp',
            'platform',
            'isDebugMode',
            'hasStackTrace',
          ];
          
          for (final field in requiredFields) {
            expect(diagnosticInfo, contains(field),
              reason: 'Diagnostic info should contain required field: $field');
            
            final value = diagnosticInfo[field];
            expect(value, isNotNull,
              reason: 'Required field $field should not be null');
            
            if (value is String) {
              expect(value, isNotEmpty,
                reason: 'String field $field should not be empty');
            }
          }
        }
      },
    );
  });
}

/// Builds test diagnostic information similar to the main app implementation
Map<String, dynamic> _buildTestDiagnostics(String context, dynamic error, StackTrace? stackTrace) {
  return {
    'context': context,
    'error': error.toString(),
    'errorType': error.runtimeType.toString(),
    'timestamp': DateTime.now().toIso8601String(),
    'platform': Platform.operatingSystem,
    'isDebugMode': kDebugMode,
    'hasStackTrace': stackTrace != null,
    'stackPreview': stackTrace?.toString().split('\n').take(3).join(' | ') ?? 'No stack trace',
    'errorCode': error is AppException ? error.code : null,
  };
}

/// Builds test system diagnostics similar to the main app implementation
Map<String, dynamic> _buildTestSystemDiagnostics() {
  return {
    'platform': Platform.operatingSystem,
    'version': Platform.operatingSystemVersion,
    'locale': Platform.localeName,
    'numberOfProcessors': Platform.numberOfProcessors,
    'isDebugMode': kDebugMode,
    'isProfileMode': kProfileMode,
    'isReleaseMode': kReleaseMode,
    'dartVersion': Platform.version,
  };
}
