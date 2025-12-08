import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/services.dart';

/// Controller de Notificações
/// 
/// Gerencia:
/// - Preferências de notificação
/// - Agendamento de notificações
/// - Permissões
/// - FCM Token
class NotificationController extends ChangeNotifier {
  final NotificationService _notificationService;
  final NotificationPreferencesRepository _repository;
  final FCMService _fcmService;

  NotificationPreferences _preferences = const NotificationPreferences();
  bool _hasPermission = false;
  bool _isLoading = false;
  String? _fcmToken;

  NotificationController(
    this._notificationService,
    this._repository,
    this._fcmService,
  );

  // Getters
  NotificationPreferences get preferences => _preferences;
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;
  String? get fcmToken => _fcmToken;

  /// Inicializa o controller
  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Inicializa o serviço de notificações locais
      await _notificationService.initialize();

      // Inicializa FCM
      await _fcmService.initialize();
      _fcmToken = _fcmService.fcmToken;

      // Salva FCM token no Firestore
      if (_fcmToken != null) {
        await _saveFCMToken(userId, _fcmToken!);
      }

      // Verifica permissão
      _hasPermission = await _notificationService.hasPermission();

      // Carrega preferências
      _preferences = await _repository.loadPreferences(userId);

      // Reagenda notificações se necessário
      if (_hasPermission) {
        await _rescheduleNotifications(userId);
      }

      debugPrint('✅ NotificationController initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationController: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva FCM token no Firestore
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _repository.saveFCMToken(userId, token);
      debugPrint('✅ FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Solicita permissão de notificações
  Future<bool> requestPermission() async {
    _hasPermission = await _notificationService.requestPermission();
    notifyListeners();
    return _hasPermission;
  }

  /// Atualiza preferências
  Future<void> updatePreferences(String userId, NotificationPreferences newPreferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Salva no Firestore
      await _repository.savePreferences(userId, newPreferences);

      // Atualiza localmente
      _preferences = newPreferences;

      // Reagenda notificações
      await _rescheduleNotifications(userId);

      debugPrint('✅ Preferences updated');
    } catch (e) {
      debugPrint('❌ Error updating preferences: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reagenda todas as notificações baseado nas preferências
  Future<void> _rescheduleNotifications(String userId) async {
    // Cancela todas as notificações existentes
    await _notificationService.cancelAllNotifications();

    // Agenda Resumo do Portfólio
    if (_preferences.portfolioSummaryEnabled) {
      await _schedulePortfolioSummary();
    }

    // Variação de Preço é monitorada em tempo real, não agendada
    // Será implementada com background tasks

    debugPrint('✅ Notifications rescheduled');
  }

  /// Agenda notificação de Resumo do Portfólio
  Future<void> _schedulePortfolioSummary() async {
    const notificationId = 1; // ID fixo para resumo do portfólio
    final hour = _preferences.getHourForTime();
    final time = Time(hour, 0, 0);

    if (_preferences.portfolioFrequency == 'daily') {
      await _notificationService.scheduleDailyNotification(
        id: notificationId,
        title: '💼 Resumo do Portfólio',
        body: 'Confira como está seu portfólio hoje!',
        time: time,
        payload: 'portfolio_summary',
      );
    } else if (_preferences.portfolioFrequency == 'weekly') {
      // Segunda-feira
      await _notificationService.scheduleWeeklyNotification(
        id: notificationId,
        title: '💼 Resumo Semanal do Portfólio',
        body: 'Confira o desempenho da semana!',
        weekday: DateTime.monday,
        time: time,
        payload: 'portfolio_summary',
      );
    }
  }

  /// Envia notificação de variação de preço
  Future<void> sendPriceVariationNotification({
    required String cryptoName,
    required String cryptoSymbol,
    required double variation,
    required double currentPrice,
  }) async {
    if (!_preferences.priceVariationEnabled || !_hasPermission) return;

    // Verifica se a variação atinge o threshold
    if (variation.abs() < _preferences.priceThreshold) return;

    final emoji = variation > 0 ? '🚀' : '📉';
    final sign = variation > 0 ? '+' : '';
    
    await _notificationService.showNotification(
      id: cryptoSymbol.hashCode, // ID único por cripto
      title: '$emoji $cryptoName ($cryptoSymbol)',
      body: 'Variação de $sign${variation.toStringAsFixed(2)}% - Preço atual: R\$ ${currentPrice.toStringAsFixed(2)}',
      payload: 'price_variation:$cryptoSymbol',
    );
  }

  /// Envia notificação de teste (DEBUG)
  Future<void> sendTestNotification() async {
    if (!_hasPermission) {
      debugPrint('❌ No permission for notifications');
      return;
    }

    await _notificationService.showNotification(
      id: 999,
      title: '🧪 Notificação de Teste',
      body: 'Se você está vendo isso, as notificações estão funcionando!',
      payload: 'test',
    );
    
    debugPrint('✅ Test notification sent');
  }

  /// Lista notificações agendadas (DEBUG)
  Future<void> listScheduledNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    debugPrint('📋 Pending notifications: ${pending.length}');
    for (final notification in pending) {
      debugPrint('  - ID: ${notification.id}, Title: ${notification.title}');
    }
  }
}
