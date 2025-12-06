import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler para mensagens em background (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message: ${message.messageId}');
  debugPrint('📦 Data: ${message.data}');
  
  // Aqui você pode processar a mensagem em background
  // Ex: salvar no banco local, atualizar cache, etc
}

/// Serviço de Firebase Cloud Messaging
/// 
/// Gerencia:
/// - Token FCM do dispositivo
/// - Recebimento de notificações push
/// - Notificações em foreground/background
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  bool _initialized = false;

  String? get fcmToken => _fcmToken;

  /// Inicializa o serviço FCM
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Solicita permissão (iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ FCM permission granted');
      } else {
        debugPrint('⚠️ FCM permission denied');
        return;
      }

      // Obtém o token FCM
      _fcmToken = await _messaging.getToken();
      debugPrint('🔑 FCM Token: $_fcmToken');

      // Configura handler para background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Configura handler para foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configura handler para quando usuário toca na notificação
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Verifica se app foi aberto por uma notificação
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Listener para quando token é atualizado
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
        // TODO: Atualizar token no Firestore
      });

      _initialized = true;
      debugPrint('✅ FCMService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing FCMService: $e');
    }
  }

  /// Handler para mensagens recebidas em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Foreground message: ${message.messageId}');
    debugPrint('📦 Data: ${message.data}');
    
    // Mostra notificação local quando app está aberto
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'CoinTrue',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handler para quando usuário toca na notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.messageId}');
    debugPrint('📦 Data: ${message.data}');
    
    // TODO: Navegar para tela específica baseado no payload
    final type = message.data['type'];
    final cryptoSymbol = message.data['cryptoSymbol'];
    
    debugPrint('Type: $type, Crypto: $cryptoSymbol');
    
    // Exemplo de navegação:
    // if (type == 'price_variation') {
    //   Navigator.pushNamed(context, '/crypto-detail', arguments: cryptoSymbol);
    // }
  }

  /// Mostra notificação local (para foreground)
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cointrue_fcm',
      'CoinTrue Push',
      channelDescription: 'Notificações push do CoinTrue',
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Subscreve a um tópico
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  /// Desinscreve de um tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('✅ Unsubscribed from topic: $topic');
  }

  /// Deleta o token FCM
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
    debugPrint('🗑️ FCM Token deleted');
  }
}
