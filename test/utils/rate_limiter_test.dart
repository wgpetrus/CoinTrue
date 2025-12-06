import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/utils/rate_limiter.dart';

void main() {
  group('Property-Based Tests - RateLimiter', () {
    late RateLimiter rateLimiter;

    setUp(() async {
      // Limpar SharedPreferences antes de cada teste
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      rateLimiter = RateLimiter(
        prefs,
        maxAttempts: 5,
        resetWindow: const Duration(minutes: 5),
        blockDuration: const Duration(minutes: 15),
      );
    });

    tearDown(() async {
      await rateLimiter.reset();
    });

    // Feature: autenticacao-cripto, Property 27: Delay progressivo em falhas
    // Validates: Requirements 6.4
    test(
      'Property 27: Para qualquer sequência de N falhas consecutivas, '
      'o sistema deve aplicar delay progressivo (1s, 2s, 4s, 8s, 16s)',
      () async {
        // Testar delays progressivos (apenas 4 tentativas para não bloquear)
        final expectedDelays = [1, 2, 4, 8];

        for (int i = 0; i < expectedDelays.length; i++) {
          final delay = await rateLimiter.recordFailedAttempt();
          
          expect(
            delay.inSeconds,
            equals(expectedDelays[i]),
            reason: 'Tentativa ${i + 1} deve ter delay de ${expectedDelays[i]}s',
          );

          final attempts = await rateLimiter.getFailedAttempts();
          expect(attempts, equals(i + 1));
        }

        // Verificar que não está bloqueado ainda (4 < maxAttempts = 5)
        final isBlocked = await rateLimiter.isBlocked();
        expect(isBlocked, isFalse);
      },
    );

    test(
      'Property 27.1: Após maxAttempts falhas, o usuário deve ser bloqueado temporariamente',
      () async {
        // Registrar 5 falhas (maxAttempts)
        for (int i = 0; i < 5; i++) {
          await rateLimiter.recordFailedAttempt();
        }

        // Verificar que está bloqueado
        final isBlocked = await rateLimiter.isBlocked();
        expect(isBlocked, isTrue);

        // Verificar tempo de bloqueio
        final remainingTime = await rateLimiter.getRemainingBlockTime();
        expect(remainingTime, isNotNull);
        expect(remainingTime!.inMinutes, greaterThanOrEqualTo(14)); // ~15 minutos
      },
    );

    test(
      'Property 27.2: Login bem-sucedido deve resetar o contador de tentativas',
      () async {
        // Registrar algumas falhas
        await rateLimiter.recordFailedAttempt();
        await rateLimiter.recordFailedAttempt();
        await rateLimiter.recordFailedAttempt();

        expect(await rateLimiter.getFailedAttempts(), equals(3));

        // Registrar sucesso
        await rateLimiter.recordSuccessfulAttempt();

        // Verificar reset
        expect(await rateLimiter.getFailedAttempts(), equals(0));
        expect(await rateLimiter.isBlocked(), isFalse);
      },
    );

    test(
      'Property 27.3: Contador deve resetar após resetWindow sem tentativas',
      () async {
        // Criar RateLimiter com janela curta para teste
        final prefs = await SharedPreferences.getInstance();
        final testLimiter = RateLimiter(
          prefs,
          maxAttempts: 5,
          resetWindow: const Duration(milliseconds: 100),
          blockDuration: const Duration(minutes: 15),
        );

        // Registrar falhas
        await testLimiter.recordFailedAttempt();
        await testLimiter.recordFailedAttempt();
        expect(await testLimiter.getFailedAttempts(), equals(2));

        // Aguardar resetWindow
        await Future.delayed(const Duration(milliseconds: 150));

        // Próxima tentativa deve resetar o contador
        await testLimiter.recordFailedAttempt();
        
        // Deve ter apenas 1 tentativa (resetou antes)
        expect(await testLimiter.getFailedAttempts(), equals(1));
      },
    );

    test(
      'Property 27.4: Bloqueio deve expirar após blockDuration',
      () async {
        // Criar RateLimiter com duração curta para teste
        final prefs = await SharedPreferences.getInstance();
        final testLimiter = RateLimiter(
          prefs,
          maxAttempts: 2,
          resetWindow: const Duration(minutes: 5),
          blockDuration: const Duration(milliseconds: 100),
        );

        // Bloquear usuário
        await testLimiter.recordFailedAttempt();
        await testLimiter.recordFailedAttempt();
        
        expect(await testLimiter.isBlocked(), isTrue);

        // Aguardar expiração
        await Future.delayed(const Duration(milliseconds: 150));

        // Verificar que não está mais bloqueado
        expect(await testLimiter.isBlocked(), isFalse);
      },
    );

    test(
      'Property 27.5: Delay máximo deve ser limitado a 16 segundos',
      () async {
        // Registrar muitas falhas
        for (int i = 0; i < 10; i++) {
          final delay = await rateLimiter.recordFailedAttempt();
          
          // Delay nunca deve exceder 16 segundos
          expect(
            delay.inSeconds,
            lessThanOrEqualTo(16),
            reason: 'Delay deve ser limitado a 16s',
          );
        }
      },
    );

    test(
      'Property 27.6: Estado deve persistir entre instâncias',
      () async {
        // Registrar falhas
        await rateLimiter.recordFailedAttempt();
        await rateLimiter.recordFailedAttempt();
        await rateLimiter.recordFailedAttempt();

        final attempts1 = await rateLimiter.getFailedAttempts();
        expect(attempts1, equals(3));

        // Criar nova instância com mesmo SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final newLimiter = RateLimiter(prefs);

        // Verificar que estado foi mantido
        final attempts2 = await newLimiter.getFailedAttempts();
        expect(attempts2, equals(3));
      },
    );

    test(
      'Property 27.7: getDebugInfo deve retornar informações corretas',
      () async {
        // Registrar algumas falhas
        await rateLimiter.recordFailedAttempt();
        await rateLimiter.recordFailedAttempt();

        final debugInfo = await rateLimiter.getDebugInfo();

        expect(debugInfo['attempts'], equals(2));
        expect(debugInfo['isBlocked'], isFalse);
        expect(debugInfo['maxAttempts'], equals(5));
        expect(debugInfo['resetWindowMinutes'], equals(5));
        expect(debugInfo['blockDurationMinutes'], equals(15));
        expect(debugInfo['lastFailure'], isNotNull);
      },
    );

    test(
      'Property 27.8: RateLimitExceededException deve ter mensagem amigável',
      () {
        final exception = RateLimitExceededException(
          'Muitas tentativas',
          const Duration(minutes: 2, seconds: 30),
        );

        final userMessage = exception.getUserMessage();
        expect(userMessage, contains('2min'));
        expect(userMessage, contains('30s'));

        // Testar com apenas segundos
        final exception2 = RateLimitExceededException(
          'Muitas tentativas',
          const Duration(seconds: 45),
        );

        final userMessage2 = exception2.getUserMessage();
        expect(userMessage2, contains('45s'));
        expect(userMessage2, isNot(contains('min')));
      },
    );
  });

  group('Edge Cases - RateLimiter', () {
    test('Deve lidar com zero tentativas', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final limiter = RateLimiter(prefs);

      expect(await limiter.getFailedAttempts(), equals(0));
      expect(await limiter.isBlocked(), isFalse);
      expect(await limiter.getRemainingBlockTime(), isNull);
    });

    test('Deve lidar com reset múltiplo', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final limiter = RateLimiter(prefs);

      await limiter.recordFailedAttempt();
      await limiter.reset();
      await limiter.reset(); // Reset duplo não deve causar erro

      expect(await limiter.getFailedAttempts(), equals(0));
    });

    test('Factory create deve funcionar corretamente', () async {
      SharedPreferences.setMockInitialValues({});
      
      final limiter = await RateLimiter.create(
        maxAttempts: 3,
        resetWindow: const Duration(minutes: 10),
        blockDuration: const Duration(minutes: 30),
      );

      expect(limiter.maxAttempts, equals(3));
      expect(limiter.resetWindow, equals(const Duration(minutes: 10)));
      expect(limiter.blockDuration, equals(const Duration(minutes: 30)));
    });
  });
}
