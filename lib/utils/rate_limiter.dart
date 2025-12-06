import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerenciador de rate limiting para prevenir ataques de força bruta
/// 
/// Implementa delay progressivo e bloqueio temporário após múltiplas falhas.
/// O estado é persistido localmente usando SharedPreferences.
/// 
/// Requisitos: 6.4
class RateLimiter {
  static const String _keyPrefix = 'rate_limiter_';
  static const String _attemptsKey = '${_keyPrefix}attempts';
  static const String _lastFailureKey = '${_keyPrefix}last_failure';
  static const String _blockedUntilKey = '${_keyPrefix}blocked_until';

  final SharedPreferences _prefs;
  
  // Configurações
  final int maxAttempts;
  final Duration resetWindow;
  final Duration blockDuration;

  /// Cria um RateLimiter com configurações customizáveis
  /// 
  /// [maxAttempts] - Número máximo de tentativas antes do bloqueio (padrão: 5)
  /// [resetWindow] - Tempo para resetar o contador (padrão: 5 minutos)
  /// [blockDuration] - Duração do bloqueio após exceder tentativas (padrão: 15 minutos)
  RateLimiter(
    this._prefs, {
    this.maxAttempts = 5,
    this.resetWindow = const Duration(minutes: 5),
    this.blockDuration = const Duration(minutes: 15),
  });

  /// Factory method para criar instância com SharedPreferences
  static Future<RateLimiter> create({
    int maxAttempts = 5,
    Duration resetWindow = const Duration(minutes: 5),
    Duration blockDuration = const Duration(minutes: 15),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return RateLimiter(
      prefs,
      maxAttempts: maxAttempts,
      resetWindow: resetWindow,
      blockDuration: blockDuration,
    );
  }

  /// Verifica se o usuário está bloqueado
  /// 
  /// Retorna true se o usuário está temporariamente bloqueado.
  Future<bool> isBlocked() async {
    final blockedUntilMs = _prefs.getInt(_blockedUntilKey);
    
    if (blockedUntilMs == null) {
      return false;
    }

    final blockedUntil = DateTime.fromMillisecondsSinceEpoch(blockedUntilMs);
    final now = DateTime.now();

    if (now.isBefore(blockedUntil)) {
      return true;
    }

    // Bloqueio expirou, limpar
    await _clearBlock();
    return false;
  }

  /// Retorna o tempo restante de bloqueio
  /// 
  /// Retorna null se não estiver bloqueado.
  Future<Duration?> getRemainingBlockTime() async {
    final blockedUntilMs = _prefs.getInt(_blockedUntilKey);
    
    if (blockedUntilMs == null) {
      return null;
    }

    final blockedUntil = DateTime.fromMillisecondsSinceEpoch(blockedUntilMs);
    final now = DateTime.now();

    if (now.isBefore(blockedUntil)) {
      return blockedUntil.difference(now);
    }

    return null;
  }

  /// Registra uma tentativa de login falhada
  /// 
  /// Incrementa o contador e aplica bloqueio se necessário.
  /// Retorna o delay que deve ser aplicado antes da próxima tentativa.
  Future<Duration> recordFailedAttempt() async {
    // Verificar se deve resetar o contador
    await _checkAndResetIfNeeded();

    // Incrementar tentativas
    final attempts = await getFailedAttempts();
    final newAttempts = attempts + 1;
    await _prefs.setInt(_attemptsKey, newAttempts);
    await _prefs.setInt(_lastFailureKey, DateTime.now().millisecondsSinceEpoch);

    debugPrint('Rate limiter: Failed attempt #$newAttempts');

    // Se excedeu o máximo, bloquear
    if (newAttempts >= maxAttempts) {
      await _blockUser();
      debugPrint('Rate limiter: User blocked for ${blockDuration.inMinutes} minutes');
    }

    // Calcular delay progressivo: 2^(attempts-1) segundos, máximo 16s
    final delaySeconds = _calculateProgressiveDelay(newAttempts);
    return Duration(seconds: delaySeconds);
  }

  /// Registra uma tentativa de login bem-sucedida
  /// 
  /// Reseta o contador de tentativas falhadas.
  Future<void> recordSuccessfulAttempt() async {
    await reset();
    debugPrint('Rate limiter: Reset after successful login');
  }

  /// Retorna o número de tentativas falhadas
  Future<int> getFailedAttempts() async {
    return _prefs.getInt(_attemptsKey) ?? 0;
  }

  /// Calcula o delay progressivo baseado no número de tentativas
  /// 
  /// Implementa: 1s, 2s, 4s, 8s, 16s (máximo)
  /// Fórmula: 2^(attempts-1), limitado a 16 segundos
  int _calculateProgressiveDelay(int attempts) {
    if (attempts <= 0) return 0;
    
    // 2^(attempts-1), limitado entre 1 e 16 segundos
    final delay = (1 << (attempts - 1)).clamp(1, 16);
    return delay;
  }

  /// Verifica se deve resetar o contador baseado na janela de tempo
  Future<void> _checkAndResetIfNeeded() async {
    final lastFailureMs = _prefs.getInt(_lastFailureKey);
    
    if (lastFailureMs == null) {
      return;
    }

    final lastFailure = DateTime.fromMillisecondsSinceEpoch(lastFailureMs);
    final now = DateTime.now();
    final timeSinceLastFailure = now.difference(lastFailure);

    // Se passou mais tempo que a janela de reset, limpar contador
    if (timeSinceLastFailure > resetWindow) {
      await reset();
      debugPrint('Rate limiter: Counter reset after ${timeSinceLastFailure.inMinutes} minutes');
    }
  }

  /// Bloqueia o usuário temporariamente
  Future<void> _blockUser() async {
    final blockedUntil = DateTime.now().add(blockDuration);
    await _prefs.setInt(_blockedUntilKey, blockedUntil.millisecondsSinceEpoch);
  }

  /// Remove o bloqueio
  Future<void> _clearBlock() async {
    await _prefs.remove(_blockedUntilKey);
  }

  /// Reseta completamente o rate limiter
  /// 
  /// Remove todas as tentativas, bloqueios e timestamps.
  Future<void> reset() async {
    await _prefs.remove(_attemptsKey);
    await _prefs.remove(_lastFailureKey);
    await _prefs.remove(_blockedUntilKey);
  }

  /// Retorna informações de debug sobre o estado atual
  Future<Map<String, dynamic>> getDebugInfo() async {
    final attempts = await getFailedAttempts();
    final isCurrentlyBlocked = await isBlocked();
    final remainingBlock = await getRemainingBlockTime();
    final lastFailureMs = _prefs.getInt(_lastFailureKey);
    
    return {
      'attempts': attempts,
      'isBlocked': isCurrentlyBlocked,
      'remainingBlockSeconds': remainingBlock?.inSeconds,
      'lastFailure': lastFailureMs != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastFailureMs).toIso8601String()
          : null,
      'maxAttempts': maxAttempts,
      'resetWindowMinutes': resetWindow.inMinutes,
      'blockDurationMinutes': blockDuration.inMinutes,
    };
  }
}

/// Exceção lançada quando o usuário está temporariamente bloqueado
class RateLimitExceededException implements Exception {
  final String message;
  final Duration remainingTime;

  const RateLimitExceededException(this.message, this.remainingTime);

  @override
  String toString() {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    
    if (minutes > 0) {
      return 'RateLimitExceededException: $message (Aguarde ${minutes}min ${seconds}s)';
    } else {
      return 'RateLimitExceededException: $message (Aguarde ${seconds}s)';
    }
  }

  /// Retorna uma mensagem amigável para o usuário
  String getUserMessage() {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    
    if (minutes > 0) {
      return 'Muitas tentativas. Aguarde ${minutes}min ${seconds}s e tente novamente.';
    } else {
      return 'Muitas tentativas. Aguarde ${seconds}s e tente novamente.';
    }
  }
}
