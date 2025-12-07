import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/exceptions.dart';
import 'auth_service.dart';

/// Firebase implementation of the AuthService interface
/// 
/// This service handles authentication using Firebase Auth as the backend,
/// supporting Google and Apple OAuth providers. It manages user sessions,
/// detects new users, and handles various error scenarios.
class FirebaseAuthService implements AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  /// Creates a FirebaseAuthService with optional dependency injection
  /// 
  /// If dependencies are not provided, default instances will be used.
  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> signInWithGoogle() async {
    try {
      debugPrint('🔵 [1/7] Iniciando Google Sign-In...');
      
      // Start Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      debugPrint('🔵 [2/7] Google Sign-In retornou: ${googleUser?.email ?? "null"}');

      // User cancelled the sign-in
      if (googleUser == null) {
        debugPrint('🔵 Usuário cancelou o login');
        throw const AuthException.cancelled();
      }

      debugPrint('🔵 [3/7] Obtendo credenciais do Google...');
      
      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      debugPrint('🔵 [4/7] Credenciais obtidas - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}');

      debugPrint('🔵 [5/7] Criando credencial Firebase...');
      
      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔵 [6/7] Fazendo login no Firebase...');
      
      // Sign in to Firebase with the credential
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      debugPrint('🔵 [7/7] Login Firebase completo - UID: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        debugPrint('❌ ERRO: userCredential.user é null!');
        throw const AuthException.invalidCredentials();
      }

      // Check if this is a new user
      bool isNewUser = false;
      bool profileComplete = false;
      
      try {
        isNewUser = await _isNewUser(userCredential.user!.uid);

        // Get profileComplete status from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        profileComplete = userDoc.exists
            ? (userDoc.data()?['profileComplete'] as bool? ?? false)
            : false;

        debugPrint('🔵 Google Login - User: ${userCredential.user!.uid}');
        debugPrint('🔵 isNewUser: $isNewUser');
        debugPrint('🔵 userDoc.exists: ${userDoc.exists}');
        debugPrint('🔵 profileComplete: $profileComplete');
        if (userDoc.exists) {
          debugPrint('🔵 Firestore data: ${userDoc.data()}');
        }
      } catch (firestoreError) {
        // If Firestore fails, continue with default values
        debugPrint('⚠️ Firestore error (continuing with defaults): $firestoreError');
        isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        profileComplete = false;
      }

      // Create User object
      final user = User.fromFirebase(
        userCredential.user!,
        provider: AuthProvider.google,
        isNewUser: isNewUser,
        profileComplete: profileComplete,
      );

      // Try to create or update user record in Firestore
      try {
        await _createUserRecord(user);
      } catch (firestoreError) {
        // If Firestore fails, log but continue - user is still authenticated
        debugPrint('⚠️ Failed to create user record in Firestore: $firestoreError');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      debugPrint('❌ ERRO CRÍTICO em signInWithGoogle: $e');
      debugPrint('❌ Tipo do erro: ${e.runtimeType}');
      debugPrint('❌ StackTrace completo:');
      debugPrint('$stackTrace');
      debugPrint('StackTrace: $stackTrace');
      throw UnexpectedException(
        'Erro ao fazer login com Google',
        e,
      );
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      // Request Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the credential
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException.invalidCredentials();
      }

      // Check if this is a new user
      bool isNewUser = false;
      bool profileComplete = false;
      
      try {
        isNewUser = await _isNewUser(userCredential.user!.uid);

        // Get profileComplete status from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        profileComplete = userDoc.exists
            ? (userDoc.data()?['profileComplete'] as bool? ?? false)
            : false;
      } catch (firestoreError) {
        // If Firestore fails, continue with default values
        debugPrint('⚠️ Firestore error (continuing with defaults): $firestoreError');
        isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        profileComplete = false;
      }

      // Create User object
      final user = User.fromFirebase(
        userCredential.user!,
        provider: AuthProvider.apple,
        isNewUser: isNewUser,
        profileComplete: profileComplete,
      );

      // Try to create user record in Firestore
      try {
        if (isNewUser) {
          await _createUserRecord(user);
        }
      } catch (firestoreError) {
        // If Firestore fails, log but continue - user is still authenticated
        debugPrint('⚠️ Failed to create user record in Firestore: $firestoreError');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException.cancelled();
      }
      throw AuthException(
        'Erro ao fazer login com Apple: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao fazer login com Apple',
        e,
      );
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        debugPrint('⚪ getCurrentUser: No user');
        return null;
      }

      debugPrint('⚪ getCurrentUser - User: ${firebaseUser.uid}');
      debugPrint('⚪ getCurrentUser - Email: ${firebaseUser.email}');

      // Determine provider from sign-in methods
      final providerData = firebaseUser.providerData;
      AuthProvider provider = AuthProvider.google;

      if (providerData.isNotEmpty) {
        final providerId = providerData.first.providerId;
        debugPrint('⚪ getCurrentUser - Provider: $providerId');
        if (providerId.contains('apple')) {
          provider = AuthProvider.apple;
        }
      }

      // Check if user exists in Firestore
      bool profileComplete = false;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        profileComplete = userDoc.exists
            ? (userDoc.data()?['profileComplete'] as bool? ?? false)
            : false;

        debugPrint('⚪ getCurrentUser - userDoc.exists: ${userDoc.exists}');
        debugPrint('⚪ getCurrentUser - profileComplete: $profileComplete');
        if (userDoc.exists) {
          debugPrint('⚪ getCurrentUser - Firestore data: ${userDoc.data()}');
        } else {
          debugPrint('⚪ getCurrentUser - WARNING: User document does NOT exist in Firestore!');
        }
      } catch (firestoreError) {
        // If Firestore fails, continue with default value
        debugPrint('⚪ getCurrentUser - Firestore error (using default): $firestoreError');
        profileComplete = false;
      }

      return User.fromFirebase(
        firebaseUser,
        provider: provider,
        isNewUser: false,
        profileComplete: profileComplete,
      );
    } catch (e) {
      debugPrint('⚪ getCurrentUser - ERROR: $e');
      // Don't throw error - return null instead to allow offline mode
      return null;
    }
  }

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw const ValidationException.emptyField('email ou senha');
      }

      // Sign in with email and password
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException.invalidCredentials();
      }

      // Check if user exists in Firestore and get profileComplete status
      bool profileComplete = false;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        profileComplete = userDoc.exists
            ? (userDoc.data()?['profileComplete'] as bool? ?? false)
            : false;

        debugPrint('🔴 Email Login - User: ${userCredential.user!.uid}');
        debugPrint('🔴 userDoc.exists: ${userDoc.exists}');
        debugPrint('🔴 profileComplete: $profileComplete');
        if (userDoc.exists) {
          debugPrint('🔴 Firestore data: ${userDoc.data()}');
        }
      } catch (firestoreError) {
        // If Firestore fails, continue with default value
        debugPrint('🔴 Firestore error (using default): $firestoreError');
        profileComplete = false;
      }

      // Create User object
      final user = User.fromFirebase(
        userCredential.user!,
        provider: AuthProvider.google, // Using google as default for email
        isNewUser: false,
        profileComplete: profileComplete,
      );

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      debugPrint('Error in signInWithEmailPassword: $e');
      debugPrint('StackTrace: $stackTrace');
      throw UnexpectedException(
        'Erro ao fazer login com email',
        e,
      );
    }
  }

  @override
  Future<User> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      // Validate inputs
      if (email.isEmpty) {
        throw const ValidationException.emptyField('email');
      }
      if (password.isEmpty) {
        throw const ValidationException.emptyField('senha');
      }
      if (displayName.isEmpty) {
        throw const ValidationException.emptyField('nome');
      }
      // Validação de senha forte para app financeiro
      if (password.length < 8) {
        throw const ValidationException(
          'A senha deve ter no mínimo 8 caracteres',
          code: 'WEAK_PASSWORD',
        );
      }
      
      // Deve conter letra maiúscula
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        throw const ValidationException(
          'A senha deve conter pelo menos uma letra maiúscula',
          code: 'WEAK_PASSWORD',
        );
      }
      
      // Deve conter letra minúscula
      if (!RegExp(r'[a-z]').hasMatch(password)) {
        throw const ValidationException(
          'A senha deve conter pelo menos uma letra minúscula',
          code: 'WEAK_PASSWORD',
        );
      }
      
      // Deve conter número
      if (!RegExp(r'[0-9]').hasMatch(password)) {
        throw const ValidationException(
          'A senha deve conter pelo menos um número',
          code: 'WEAK_PASSWORD',
        );
      }
      
      // Deve conter caractere especial
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        throw const ValidationException(
          'A senha deve conter pelo menos um caractere especial (!@#\$%^&*)',
          code: 'WEAK_PASSWORD',
        );
      }

      // Create user with email and password
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException(
          'Erro ao criar conta',
          code: 'USER_CREATION_FAILED',
        );
      }

      // Update display name
      await userCredential.user!.updateDisplayName(displayName.trim());
      
      // Send email verification
      await userCredential.user!.sendEmailVerification();
      
      await userCredential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser;

      if (updatedUser == null) {
        throw const AuthException(
          'Erro ao atualizar perfil',
          code: 'PROFILE_UPDATE_FAILED',
        );
      }

      // Create User object
      final user = User.fromFirebase(
        updatedUser,
        provider: AuthProvider.google, // Using google as default for email
        isNewUser: true,
      );

      // Create user record in Firestore
      await _createUserRecord(user);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      debugPrint('Error in signUpWithEmailPassword: $e');
      debugPrint('StackTrace: $stackTrace');
      throw UnexpectedException(
        'Erro ao criar conta',
        e,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Validate input
      if (email.isEmpty) {
        throw const ValidationException.emptyField('email');
      }

      // Send password reset email
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } on TimeoutException catch (_) {
      throw const NetworkException.timeout();
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      debugPrint('Error in sendPasswordResetEmail: $e');
      debugPrint('StackTrace: $stackTrace');
      throw UnexpectedException(
        'Erro ao enviar email de recuperação',
        e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } catch (e) {
      throw UnexpectedException(
        'Erro ao fazer logout',
        e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw const AuthException(
          'Nenhum usuário autenticado',
          code: 'NO_USER',
        );
      }

      // Reload user to get fresh token (helps with requires-recent-login)
      try {
        await user.reload();
        await user.getIdToken(true); // Force refresh token
      } catch (e) {
        debugPrint('Error reloading user: $e');
        // Continue anyway
      }

      // Delete user document from Firestore
      try {
        await _firestore.collection('users').doc(user.uid).delete();
      } catch (e) {
        debugPrint('Error deleting user document: $e');
        // Continue even if Firestore deletion fails
      }

      // Delete user from Firebase Auth
      await user.delete();

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'A autenticação expirou. Por favor, saia e faça login novamente antes de excluir sua conta.',
          code: 'REQUIRES_RECENT_LOGIN',
        );
      }
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao excluir conta',
        e,
      );
    }
  }

  @override
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw const AuthException(
          'Nenhum usuário autenticado',
          code: 'NO_USER',
        );
      }

      if (user.email == null) {
        throw const AuthException(
          'Usuário não possui email',
          code: 'NO_EMAIL',
        );
      }

      // Re-authenticate with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update email in Firestore (mantém profileComplete como true)
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
        'profileComplete': true, // Garante que não volta para onboarding
      });

    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const AuthException(
          'Este email já está em uso',
          code: 'EMAIL_ALREADY_IN_USE',
        );
      } else if (e.code == 'invalid-email') {
        throw const AuthException(
          'Email inválido',
          code: 'INVALID_EMAIL',
        );
      } else if (e.code == 'wrong-password') {
        throw const AuthException(
          'Senha incorreta',
          code: 'INVALID_CREDENTIALS',
        );
      } else if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Por segurança, faça login novamente',
          code: 'REQUIRES_RECENT_LOGIN',
        );
      }
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao atualizar email',
        e,
      );
    }
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw const AuthException(
          'Nenhum usuário autenticado',
          code: 'NO_USER',
        );
      }

      if (user.email == null) {
        throw const AuthException(
          'Usuário não possui email',
          code: 'NO_EMAIL',
        );
      }

      debugPrint('🟠 FirebaseAuthService: Re-authenticating with current password...');
      
      // Re-authenticate with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      debugPrint('🟠 FirebaseAuthService: Re-authentication successful');
      debugPrint('🟠 FirebaseAuthService: Updating password...');

      // Update password
      await user.updatePassword(newPassword);
      
      debugPrint('🟠 FirebaseAuthService: Password updated successfully');

    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('🟠 FirebaseAuthService: FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        throw const AuthException(
          'A senha é muito fraca. Use pelo menos 6 caracteres',
          code: 'WEAK_PASSWORD',
        );
      } else if (e.code == 'wrong-password') {
        throw const AuthException(
          'Senha atual incorreta',
          code: 'INVALID_CREDENTIALS',
        );
      } else if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Por segurança, faça login novamente',
          code: 'REQUIRES_RECENT_LOGIN',
        );
      }
      throw _handleFirebaseAuthException(e);
    } on SocketException catch (_) {
      throw const NetworkException.noConnection();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnexpectedException(
        'Erro ao atualizar senha',
        e,
      );
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        debugPrint('🟣 authStateChanges: No user');
        return null;
      }

      debugPrint('🟣 authStateChanges: User ${firebaseUser.uid}');

      // Determine provider
      final providerData = firebaseUser.providerData;
      AuthProvider provider = AuthProvider.google;

      if (providerData.isNotEmpty) {
        final providerId = providerData.first.providerId;
        if (providerId.contains('apple')) {
          provider = AuthProvider.apple;
        }
      }

      // Check profile completion status
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final bool profileComplete = userDoc.exists
          ? (userDoc.data()?['profileComplete'] as bool? ?? false)
          : false;

      debugPrint('🟣 authStateChanges - userDoc.exists: ${userDoc.exists}');
      debugPrint('🟣 authStateChanges - profileComplete: $profileComplete');
      if (userDoc.exists) {
        debugPrint('🟣 authStateChanges - Firestore data: ${userDoc.data()}');
      }

      return User.fromFirebase(
        firebaseUser,
        provider: provider,
        isNewUser: false,
        profileComplete: profileComplete,
      );
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  /// Checks if a user is new by verifying existence in Firestore
  /// 
  /// Returns true if the user document doesn't exist in Firestore,
  /// indicating this is the user's first login.
  Future<bool> _isNewUser(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      return !userDoc.exists;
    } catch (e) {
      // If we can't check, assume not new to avoid creating duplicate records
      return false;
    }
  }

  /// Creates a basic user record in Firestore for new users
  /// 
  /// Stores essential user information from OAuth provider.
  /// Only creates if document doesn't exist (doesn't overwrite existing data).
  Future<void> _createUserRecord(User user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.id);
      final doc = await docRef.get();
      
      debugPrint('🟢 _createUserRecord - User: ${user.id}');
      debugPrint('🟢 Document exists: ${doc.exists}');
      
      // Só cria se o documento NÃO existir
      if (!doc.exists) {
        debugPrint('🟢 Creating NEW user document with profileComplete: false');
        await docRef.set({
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
          'provider': user.provider.name,
          'createdAt': user.createdAt.toIso8601String(),
          'profileComplete': false,
        });
      } else {
        debugPrint('🟢 Updating EXISTING user document (keeping profileComplete)');
        final currentData = doc.data();
        debugPrint('🟢 Current profileComplete: ${currentData?['profileComplete']}');
        
        await docRef.update({
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Log error but don't throw - user is authenticated even if record creation fails
      // This will be retried on next login
      debugPrint('🔴 Error creating/updating user record: $e');
    }
  }

  /// Handles Firebase Auth exceptions and converts them to app-specific exceptions
  AppException _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return const NetworkException.noConnection();

      case 'user-not-found':
        return const AuthException(
          'Email não encontrado. Verifique ou crie uma conta.',
          code: 'USER_NOT_FOUND',
        );

      case 'user-disabled':
        return const AuthException.accountDisabled();

      case 'invalid-credential':
      case 'wrong-password':
        return const AuthException(
          'Email ou senha incorretos. Tente novamente.',
          code: 'INVALID_CREDENTIALS',
        );

      case 'invalid-email':
        return const AuthException(
          'Email inválido. Verifique o formato.',
          code: 'INVALID_EMAIL',
        );

      case 'email-already-in-use':
        return const AuthException(
          'Este email já possui uma conta. Faça login ou recupere sua senha.',
          code: 'EMAIL_IN_USE',
        );

      case 'weak-password':
        return const AuthException(
          'Senha muito fraca. Use no mínimo 6 caracteres.',
          code: 'WEAK_PASSWORD',
        );

      case 'too-many-requests':
        return const AuthException(
          'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
          code: 'TOO_MANY_REQUESTS',
        );

      case 'operation-not-allowed':
        return const AuthException.serviceUnavailable();

      default:
        return AuthException(
          'Erro de autenticação: ${e.message ?? 'Erro desconhecido'}',
          code: e.code,
          originalError: e,
        );
    }
  }
}
