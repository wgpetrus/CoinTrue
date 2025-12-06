import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';

import 'package:login/services/firebase_auth_service.dart';
import 'package:login/models/user.dart';
import 'package:login/models/exceptions.dart';

import 'firebase_auth_service_test.mocks.dart';

// Generate mocks for the dependencies
@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.UserCredential,
  firebase_auth.User,
  firebase_auth.UserMetadata,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFirebaseFirestore mockFirestore;
  late FirebaseAuthService authService;
  late Faker faker;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockFirestore = MockFirebaseFirestore();
    faker = Faker();

    authService = FirebaseAuthService(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      firestore: mockFirestore,
    );
  });

  group('Property-Based Tests - FirebaseAuthService', () {
    // Feature: autenticacao-cripto, Property 5: Detecção e redirecionamento de novo usuário
    // Validates: Requirements 1.5, 8.1, 8.2
    test(
      'Property 5: Para qualquer usuário fazendo login pela primeira vez, '
      'o sistema deve criar um registro com isNewUser=true e dados do OAuth',
      () async {
        // Run 100 iterations with random data
        for (int i = 0; i < 100; i++) {
          // Reset mocks for each iteration
          reset(mockFirebaseAuth);
          reset(mockGoogleSignIn);
          reset(mockFirestore);

          // Generate random user data for a NEW user
          final randomEmail = faker.internet.email();
          final randomUserId = faker.guid.guid();
          final randomDisplayName = faker.person.name();
          final randomPhotoUrl = faker.internet.httpsUrl();

          // Setup mock Firebase User
          final mockFirebaseUser = MockUser();
          when(mockFirebaseUser.uid).thenReturn(randomUserId);
          when(mockFirebaseUser.email).thenReturn(randomEmail);
          when(mockFirebaseUser.displayName).thenReturn(randomDisplayName);
          when(mockFirebaseUser.photoURL).thenReturn(randomPhotoUrl);

          final mockMetadata = MockUserMetadata();
          final creationTime = DateTime.now();
          when(mockMetadata.creationTime).thenReturn(creationTime);
          when(mockFirebaseUser.metadata).thenReturn(mockMetadata);

          final mockProviderData = <firebase_auth.UserInfo>[];
          when(mockFirebaseUser.providerData).thenReturn(mockProviderData);

          // Setup mock Google Sign-In flow
          final mockGoogleUser = MockGoogleSignInAccount();
          final mockGoogleAuth = MockGoogleSignInAuthentication();

          when(mockGoogleAuth.accessToken).thenReturn('mock_access_token');
          when(mockGoogleAuth.idToken).thenReturn('mock_id_token');
          when(mockGoogleUser.authentication)
              .thenAnswer((_) async => mockGoogleAuth);
          when(mockGoogleSignIn.signIn())
              .thenAnswer((_) async => mockGoogleUser);

          // Setup mock UserCredential
          final mockUserCredential = MockUserCredential();
          when(mockUserCredential.user).thenReturn(mockFirebaseUser);
          when(mockFirebaseAuth.signInWithCredential(any))
              .thenAnswer((_) async => mockUserCredential);

          // Setup Firestore mocks - NEW USER (document doesn't exist)
          final mockCollection = MockCollectionReference<Map<String, dynamic>>();
          final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
          final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

          when(mockFirestore.collection('users')).thenReturn(mockCollection);
          when(mockCollection.doc(randomUserId)).thenReturn(mockDocRef);
          when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
          
          // User doesn't exist in Firestore (new user)
          when(mockDocSnapshot.exists).thenReturn(false);

          // Mock the set operation for creating new user record
          when(mockDocRef.set(any)).thenAnswer((_) async => {});

          // Act: Perform sign in
          final user = await authService.signInWithGoogle();

          // Assert: Verify new user detection
          expect(user.isNewUser, isTrue, 
            reason: 'User should be marked as new when not in Firestore');

          // Assert: Verify user has OAuth data
          expect(user.id, equals(randomUserId));
          expect(user.email, equals(randomEmail));
          expect(user.displayName, equals(randomDisplayName));
          expect(user.photoUrl, equals(randomPhotoUrl));
          expect(user.provider, equals(AuthProvider.google));
          expect(user.createdAt, isNotNull);

          // Assert: Verify basic record was created in Firestore
          final captured = verify(mockDocRef.set(captureAny)).captured;
          expect(captured.length, equals(1));
          
          final recordData = captured[0] as Map<String, dynamic>;
          expect(recordData['email'], equals(randomEmail));
          expect(recordData['displayName'], equals(randomDisplayName));
          expect(recordData['photoUrl'], equals(randomPhotoUrl));
          expect(recordData['provider'], equals('google'));
          expect(recordData['profileComplete'], isFalse);
          expect(recordData['createdAt'], isNotNull);
        }
      },
    );

    // Feature: autenticacao-cripto, Property 3: Criação ou recuperação de perfil
    // Validates: Requirements 1.3
    test(
      'Property 3: Para qualquer login social bem-sucedido, '
      'o sistema deve criar um novo perfil se não existir '
      'ou recuperar o perfil existente do Firebase Auth',
      () async {
        // Run 100 iterations with random data
        for (int i = 0; i < 100; i++) {
          // Reset mocks for each iteration
          reset(mockFirebaseAuth);
          reset(mockGoogleSignIn);
          reset(mockFirestore);

          // Generate random user data
          final randomEmail = faker.internet.email();
          final randomUserId = faker.guid.guid();
          final randomDisplayName = faker.person.name();
          final randomPhotoUrl = faker.internet.httpsUrl();
          final isNewUser = faker.randomGenerator.boolean();

          // Setup mock Firebase User
          final mockFirebaseUser = MockUser();
          when(mockFirebaseUser.uid).thenReturn(randomUserId);
          when(mockFirebaseUser.email).thenReturn(randomEmail);
          when(mockFirebaseUser.displayName).thenReturn(randomDisplayName);
          when(mockFirebaseUser.photoURL).thenReturn(randomPhotoUrl);

          final mockMetadata = MockUserMetadata();
          when(mockMetadata.creationTime).thenReturn(DateTime.now());
          when(mockFirebaseUser.metadata).thenReturn(mockMetadata);

          final mockProviderData = <firebase_auth.UserInfo>[];
          when(mockFirebaseUser.providerData).thenReturn(mockProviderData);

          // Setup mock Google Sign-In flow
          final mockGoogleUser = MockGoogleSignInAccount();
          final mockGoogleAuth = MockGoogleSignInAuthentication();

          when(mockGoogleAuth.accessToken).thenReturn('mock_access_token');
          when(mockGoogleAuth.idToken).thenReturn('mock_id_token');
          when(mockGoogleUser.authentication)
              .thenAnswer((_) async => mockGoogleAuth);
          when(mockGoogleSignIn.signIn())
              .thenAnswer((_) async => mockGoogleUser);

          // Setup mock UserCredential
          final mockUserCredential = MockUserCredential();
          when(mockUserCredential.user).thenReturn(mockFirebaseUser);
          when(mockFirebaseAuth.signInWithCredential(any))
              .thenAnswer((_) async => mockUserCredential);

          // Setup Firestore mocks
          final mockCollection = MockCollectionReference<Map<String, dynamic>>();
          final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
          final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

          when(mockFirestore.collection('users')).thenReturn(mockCollection);
          when(mockCollection.doc(randomUserId)).thenReturn(mockDocRef);
          when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

          // Configure whether user exists in Firestore
          when(mockDocSnapshot.exists).thenReturn(!isNewUser);

          if (!isNewUser) {
            // Existing user - mock Firestore data
            when(mockDocSnapshot.data()).thenReturn({
              'email': randomEmail,
              'displayName': randomDisplayName,
              'photoUrl': randomPhotoUrl,
              'provider': 'google',
              'createdAt': DateTime.now().toIso8601String(),
              'profileComplete': false,
            });
          }

          // Mock the set operation for new users
          when(mockDocRef.set(any)).thenAnswer((_) async => {});

          // Act: Perform sign in
          final user = await authService.signInWithGoogle();

          // Assert: Verify user object is created correctly
          expect(user, isNotNull);
          expect(user.id, equals(randomUserId));
          expect(user.email, equals(randomEmail));
          expect(user.displayName, equals(randomDisplayName));
          expect(user.photoUrl, equals(randomPhotoUrl));
          expect(user.provider, equals(AuthProvider.google));

          // Verify Firestore interaction
          // The service calls collection('users') for checking if user exists
          // and again for creating record if new user
          verify(mockFirestore.collection('users')).called(greaterThanOrEqualTo(1));
          
          // The service calls doc(userId) for checking existence
          // and again for creating record if new user (so 1 or 2 times)
          final docCalls = verify(mockCollection.doc(randomUserId)).callCount;
          expect(docCalls, greaterThanOrEqualTo(1));
          
          // The service calls get() multiple times:
          // 1. To check if user exists (_isNewUser)
          // 2. To get profileComplete status
          // 3. Additional checks during user creation flow
          verify(mockDocRef.get()).called(greaterThanOrEqualTo(2));

          if (isNewUser) {
            // For new users, verify profile creation was attempted
            verify(mockDocRef.set(any)).called(1);
            expect(user.isNewUser, isTrue);
          } else {
            // For existing users, verify no profile creation
            verifyNever(mockDocRef.set(any));
          }
        }
      },
    );
  });
}
