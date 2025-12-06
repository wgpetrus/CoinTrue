import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/exceptions.dart';
import 'user_repository.dart';

/// Firebase implementation of the UserRepository interface
/// 
/// This repository handles user data persistence using Cloud Firestore
/// as the backend. It manages CRUD operations for user records and
/// handles various error scenarios appropriately.
/// 
/// User documents are stored in the 'users' collection with the
/// user's ID as the document ID.
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  /// Creates a FirebaseUserRepository with optional dependency injection
  /// 
  /// If [firestore] is not provided, the default Firestore instance
  /// will be used.
  FirebaseUserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> createUser(User user) async {
    try {
      // Validate user data
      if (user.id.isEmpty) {
        throw const ValidationException(
          'ID do usuário não pode estar vazio',
          code: 'EMPTY_USER_ID',
        );
      }

      if (user.email.isEmpty) {
        throw const ValidationException.emptyField('email');
      }

      // Check if user already exists
      final exists = await userExists(user.id);
      if (exists) {
        throw AuthException(
          'Usuário com ID ${user.id} já existe',
          code: 'USER_ALREADY_EXISTS',
        );
      }

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'provider': user.provider.name,
        'createdAt': user.createdAt.toIso8601String(),
        'isNewUser': user.isNewUser,
        'profileComplete': user.profileComplete,
      });

      return user;
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'criar usuário');
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao criar usuário',
        e,
      );
    }
  }

  @override
  Future<User?> getUser(String userId) async {
    try {
      // Validate input
      if (userId.isEmpty) {
        throw const ValidationException(
          'ID do usuário não pode estar vazio',
          code: 'EMPTY_USER_ID',
        );
      }

      // Fetch user document from Firestore
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      // Return null if user doesn't exist
      if (!docSnapshot.exists) {
        return null;
      }

      // Convert Firestore document to User object
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }

      return _userFromFirestore(userId, data);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'buscar usuário');
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao buscar usuário',
        e,
      );
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      // Validate user data
      if (user.id.isEmpty) {
        throw const ValidationException(
          'ID do usuário não pode estar vazio',
          code: 'EMPTY_USER_ID',
        );
      }

      if (user.email.isEmpty) {
        throw const ValidationException.emptyField('email');
      }

      // Check if user exists
      final exists = await userExists(user.id);
      if (!exists) {
        throw const AuthException.userNotFound();
      }

      // Update user document in Firestore
      await _firestore.collection('users').doc(user.id).update({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'provider': user.provider.name,
        'isNewUser': user.isNewUser,
        'profileComplete': user.profileComplete,
        // Note: createdAt is not updated as it should remain immutable
      });
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'atualizar usuário');
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao atualizar usuário',
        e,
      );
    }
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      // Validate input
      if (userId.isEmpty) {
        throw const ValidationException(
          'ID do usuário não pode estar vazio',
          code: 'EMPTY_USER_ID',
        );
      }

      // Check if user document exists in Firestore
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      return docSnapshot.exists;
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'verificar existência do usuário');
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao verificar existência do usuário',
        e,
      );
    }
  }

  /// Converts Firestore document data to a User object
  /// 
  /// Handles missing or null fields gracefully by providing defaults.
  User _userFromFirestore(String userId, Map<String, dynamic> data) {
    return User(
      id: userId,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      provider: _parseAuthProvider(data['provider'] as String?),
      createdAt: _parseDateTime(data['createdAt'] as String?),
      isNewUser: data['isNewUser'] as bool? ?? false,
      profileComplete: data['profileComplete'] as bool? ?? false,
    );
  }

  /// Parses an AuthProvider from a string value
  /// 
  /// Returns AuthProvider.google as default if parsing fails.
  AuthProvider _parseAuthProvider(String? providerString) {
    if (providerString == null) {
      return AuthProvider.google;
    }

    try {
      return AuthProvider.values.firstWhere(
        (e) => e.name == providerString,
        orElse: () => AuthProvider.google,
      );
    } catch (_) {
      return AuthProvider.google;
    }
  }

  /// Parses a DateTime from an ISO 8601 string
  /// 
  /// Returns current DateTime if parsing fails.
  DateTime _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return DateTime.now();
    }

    try {
      return DateTime.parse(dateTimeString);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Handles Firestore exceptions and converts them to app-specific exceptions
  AppException _handleFirestoreException(
    FirebaseException e,
    String operation,
  ) {
    switch (e.code) {
      case 'unavailable':
        return const NetworkException(
          'Serviço temporariamente indisponível. Tente novamente mais tarde.',
          code: 'SERVICE_UNAVAILABLE',
        );

      case 'permission-denied':
        return AuthException(
          'Permissão negada para $operation',
          code: 'PERMISSION_DENIED',
          originalError: e,
        );

      case 'not-found':
        return const AuthException.userNotFound();

      case 'already-exists':
        return AuthException(
          'Usuário já existe',
          code: 'USER_ALREADY_EXISTS',
          originalError: e,
        );

      case 'deadline-exceeded':
        return const NetworkException.timeout();

      default:
        return UnexpectedException(
          'Erro ao $operation: ${e.message ?? 'Erro desconhecido'}',
          e,
        );
    }
  }
}
