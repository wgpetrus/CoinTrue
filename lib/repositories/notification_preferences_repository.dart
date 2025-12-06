import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_preferences.dart';

/// Repositório de Preferências de Notificações
/// 
/// Gerencia o armazenamento das preferências no Firestore
class NotificationPreferencesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Salva as preferências do usuário
  Future<void> savePreferences(String userId, NotificationPreferences preferences) async {
    try {
      await _firestore
          .collection('notification_preferences')
          .doc(userId)
          .set(preferences.toMap(), SetOptions(merge: true));
      
      debugPrint('✅ Notification preferences saved for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving notification preferences: $e');
      rethrow;
    }
  }

  /// Carrega as preferências do usuário
  Future<NotificationPreferences> loadPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('notification_preferences')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return NotificationPreferences.fromMap(doc.data()!);
      }

      // Retorna preferências padrão se não existir
      return const NotificationPreferences();
    } catch (e) {
      debugPrint('❌ Error loading notification preferences: $e');
      return const NotificationPreferences();
    }
  }

  /// Deleta as preferências do usuário
  Future<void> deletePreferences(String userId) async {
    try {
      await _firestore
          .collection('notification_preferences')
          .doc(userId)
          .delete();
      
      debugPrint('✅ Notification preferences deleted for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting notification preferences: $e');
    }
  }

  /// Salva o FCM token do usuário
  Future<void> saveFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore
          .collection('notification_preferences')
          .doc(userId)
          .set({
            'fcmToken': fcmToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      debugPrint('✅ FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
      rethrow;
    }
  }
}
