import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';

// Time class para representar horário
class Time {
  final int hour;
  final int minute;
  final int second;
  
  const Time(this.hour, this.minute, [this.second = 0]);
}

/// Serviço de Notificações Locais
/// 
/// Gerencia:
/// - Permissões de notificação
/// - Agendamento de notificações
/// - Notificações imediatas
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializa timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    // Configurações Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  /// Callback quando notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // TODO: Navegar para tela específica baseado no payload
  }

  /// Solicita permissão de notificações
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android 13+ precisa de permissão explícita
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS sempre precisa de permissão
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  /// Verifica se tem permissão
  Future<bool> hasPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.notification.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: false,
            badge: false,
            sound: false,
          );
      return granted ?? false;
    }
    return true;
  }

  /// Mostra notificação imediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cointrue_channel',
      'CoinTrue',
      channelDescription: 'Notificações do app CoinTrue',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('🔔 Notification shown: $title');
  }

  /// Agenda notificação para horário específico
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cointrue_channel',
      'CoinTrue',
      channelDescription: 'Notificações do app CoinTrue',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('🔔 Notification scheduled for: $scheduledDate');
  }

  /// Agenda notificação diária
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required Time time,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cointrue_channel',
      'CoinTrue',
      channelDescription: 'Notificações do app CoinTrue',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    debugPrint('🔔 Daily notification scheduled for: ${time.hour}:${time.minute}');
  }

  /// Agenda notificação semanal
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday, // 1 = Monday, 7 = Sunday
    required Time time,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cointrue_channel',
      'CoinTrue',
      channelDescription: 'Notificações do app CoinTrue',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekday(weekday, time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );

    debugPrint('🔔 Weekly notification scheduled for weekday $weekday at ${time.hour}:${time.minute}');
  }

  /// Cancela notificação específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔕 Notification $id cancelled');
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔕 All notifications cancelled');
  }

  /// Lista notificações pendentes (DEBUG)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Calcula próxima instância de um horário
  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    // Se o horário já passou hoje, agenda para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Calcula próxima instância de um dia da semana e horário
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, Time time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    // Ajusta para o dia da semana correto
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Se o horário já passou nesta semana, agenda para próxima semana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
}
