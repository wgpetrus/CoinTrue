import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço para gerenciar fotos de perfil
/// 
/// Funcionalidades:
/// - Selecionar foto da galeria ou câmera
/// - Upload para Firebase Storage
/// - Salvar URL no Firestore
/// - Cache local da imagem
class ProfileImageService {
  static final ProfileImageService _instance = ProfileImageService._internal();
  factory ProfileImageService() => _instance;
  ProfileImageService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seleciona imagem da galeria
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        debugPrint('✅ Image selected from gallery: ${image.path}');
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      return null;
    }
  }

  /// Seleciona imagem da câmera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        debugPrint('✅ Image captured from camera: ${image.path}');
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error capturing image from camera: $e');
      return null;
    }
  }

  /// Faz upload da imagem para Firebase Storage
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      debugPrint('📤 Uploading profile image for user: $userId');
      
      // Verificar se o arquivo existe
      if (!await imageFile.exists()) {
        debugPrint('❌ Image file does not exist');
        throw Exception('Arquivo de imagem não encontrado');
      }
      
      // Referência do arquivo no Storage
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      
      // Metadata da imagem
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload do arquivo com timeout
      final uploadTask = ref.putFile(imageFile, metadata);
      
      // Aguardar upload com timeout de 30 segundos
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tempo limite de upload excedido');
        },
      );
      
      // Obter URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
      
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error uploading profile image: ${e.code} - ${e.message}');
      
      // Mensagens de erro mais amigáveis
      if (e.code == 'object-not-found') {
        throw Exception('Erro de configuração do Firebase Storage. Entre em contato com o suporte.');
      } else if (e.code == 'unauthorized') {
        throw Exception('Você não tem permissão para fazer upload de imagens.');
      } else if (e.code == 'canceled') {
        throw Exception('Upload cancelado.');
      } else {
        throw Exception('Erro ao fazer upload: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Salva URL da foto no perfil do usuário
  Future<bool> saveProfileImageUrl(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Profile image URL saved to Firestore');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error saving profile image URL: $e');
      return false;
    }
  }

  /// Processo completo: selecionar, upload e salvar
  Future<String?> updateProfileImage(String userId, {bool fromCamera = false}) async {
    try {
      // 1. Selecionar imagem
      final File? imageFile = fromCamera 
          ? await pickImageFromCamera()
          : await pickImageFromGallery();
      
      if (imageFile == null) {
        debugPrint('⚠️ No image selected');
        return null;
      }

      // 2. Upload para Storage
      final String? imageUrl = await uploadProfileImage(userId, imageFile);
      
      if (imageUrl == null) {
        debugPrint('❌ Failed to upload image');
        throw Exception('Falha ao fazer upload da imagem');
      }

      // 3. Salvar URL no Firestore
      final bool saved = await saveProfileImageUrl(userId, imageUrl);
      
      if (!saved) {
        debugPrint('❌ Failed to save image URL');
        throw Exception('Falha ao salvar URL da imagem');
      }

      debugPrint('🎉 Profile image updated successfully!');
      return imageUrl;
      
    } catch (e) {
      debugPrint('❌ Error in updateProfileImage: $e');
      rethrow; // Propagar erro para mostrar mensagem ao usuário
    }
  }

  /// Remove foto de perfil
  Future<bool> removeProfileImage(String userId) async {
    try {
      // Remove do Storage
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.delete();
      
      // Remove URL do Firestore
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Profile image removed successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error removing profile image: $e');
      return false;
    }
  }
}