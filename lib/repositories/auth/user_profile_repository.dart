import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/models.dart';

/// Repository para gerenciar perfis de usuários no Firestore
class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cria ou atualiza o perfil do usuário
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(profile.userId)
          .set(profile.toMap());
      
      debugPrint('UserProfileRepository: Profile saved for user ${profile.userId}');
    } catch (e) {
      debugPrint('UserProfileRepository: Error saving profile: $e');
      rethrow;
    }
  }

  /// Busca o perfil do usuário
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('UserProfileRepository: Profile not found for user $userId');
        return null;
      }

      return UserProfile.fromMap(doc.data()!, userId);
    } catch (e) {
      debugPrint('UserProfileRepository: Error getting profile: $e');
      rethrow;
    }
  }

  /// Atualiza campos específicos do perfil
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore
          .collection('user_profiles')
          .doc(userId)
          .update(updates);
      
      debugPrint('UserProfileRepository: Profile updated for user $userId');
    } catch (e) {
      debugPrint('UserProfileRepository: Error updating profile: $e');
      rethrow;
    }
  }

  /// Verifica se o perfil está completo
  Future<bool> isProfileComplete(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();

      if (!doc.exists) return false;

      return doc.data()?['profileComplete'] as bool? ?? false;
    } catch (e) {
      debugPrint('UserProfileRepository: Error checking profile completion: $e');
      return false;
    }
  }

  /// Deleta o perfil do usuário
  Future<void> deleteProfile(String userId) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(userId)
          .delete();
      
      debugPrint('UserProfileRepository: Profile deleted for user $userId');
    } catch (e) {
      debugPrint('UserProfileRepository: Error deleting profile: $e');
      rethrow;
    }
  }
}
