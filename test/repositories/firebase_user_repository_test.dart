import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';

import 'package:login/repositories/firebase_user_repository.dart';
import 'package:login/models/user.dart';
import 'package:login/models/exceptions.dart';

import 'firebase_user_repository_test.mocks.dart';

// Generate mocks for Firestore dependencies
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late FirebaseUserRepository repository;
  late Faker faker;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    faker = Faker();

    repository = FirebaseUserRepository(firestore: mockFirestore);

    // Default setup for Firestore mocks
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
  });

  group('FirebaseUserRepository - createUser', () {
    test('deve criar usuário com sucesso quando dados são válidos', () async {
      // Arrange
      final user = User(
        id: faker.guid.guid(),
        email: faker.internet.email(),
        displayName: faker.person.name(),
        photoUrl: faker.internet.httpsUrl(),
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: true,
        profileComplete: false,
      );

      when(mockCollection.doc(user.id)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false); // User doesn't exist
      when(mockDocRef.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.createUser(user);

      // Assert
      expect(result, equals(user));
      verify(mockDocRef.set(any)).called(1);
    });

    test('deve lançar ValidationException quando ID está vazio', () async {
      // Arrange
      final user = User(
        id: '',
        email: faker.internet.email(),
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: true,
      );

      // Act & Assert
      expect(
        () => repository.createUser(user),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deve lançar ValidationException quando email está vazio', () async {
      // Arrange
      final user = User(
        id: faker.guid.guid(),
        email: '',
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: true,
      );

      // Act & Assert
      expect(
        () => repository.createUser(user),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deve lançar AuthException quando usuário já existe', () async {
      // Arrange
      final user = User(
        id: faker.guid.guid(),
        email: faker.internet.email(),
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: true,
      );

      when(mockCollection.doc(user.id)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true); // User already exists

      // Act & Assert
      expect(
        () => repository.createUser(user),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('FirebaseUserRepository - getUser', () {
    test('deve recuperar usuário existente com sucesso', () async {
      // Arrange
      final userId = faker.guid.guid();
      final email = faker.internet.email();
      final displayName = faker.person.name();
      final photoUrl = faker.internet.httpsUrl();
      final createdAt = DateTime.now();

      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'provider': 'google',
        'createdAt': createdAt.toIso8601String(),
        'isNewUser': false,
        'profileComplete': true,
      });

      // Act
      final result = await repository.getUser(userId);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(userId));
      expect(result.email, equals(email));
      expect(result.displayName, equals(displayName));
      expect(result.photoUrl, equals(photoUrl));
      expect(result.provider, equals(AuthProvider.google));
      expect(result.isNewUser, isFalse);
      expect(result.profileComplete, isTrue);
    });

    test('deve retornar null quando usuário não existe', () async {
      // Arrange
      final userId = faker.guid.guid();

      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.getUser(userId);

      // Assert
      expect(result, isNull);
    });

    test('deve lançar ValidationException quando userId está vazio', () async {
      // Act & Assert
      expect(
        () => repository.getUser(''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deve retornar null quando documento existe mas data é null', () async {
      // Arrange
      final userId = faker.guid.guid();

      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(null);

      // Act
      final result = await repository.getUser(userId);

      // Assert
      expect(result, isNull);
    });
  });

  group('FirebaseUserRepository - updateUser', () {
    test('deve atualizar usuário existente com sucesso', () async {
      // Arrange
      final user = User(
        id: faker.guid.guid(),
        email: faker.internet.email(),
        displayName: faker.person.name(),
        photoUrl: faker.internet.httpsUrl(),
        provider: AuthProvider.apple,
        createdAt: DateTime.now(),
        isNewUser: false,
        profileComplete: true,
      );

      when(mockCollection.doc(user.id)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true); // User exists
      when(mockDocRef.update(any)).thenAnswer((_) async => {});

      // Act
      await repository.updateUser(user);

      // Assert
      verify(mockDocRef.update(any)).called(1);
    });

    test('deve lançar ValidationException quando ID está vazio', () async {
      // Arrange
      final user = User(
        id: '',
        email: faker.internet.email(),
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: false,
      );

      // Act & Assert
      expect(
        () => repository.updateUser(user),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deve lançar ValidationException quando email está vazio', () async {
      // Arrange
      final user = User(
        id: faker.guid.guid(),
        email: '',
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: false,
      );

      // Act & Assert
      expect(
        () => repository.updateUser(user),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deve lançar AuthException quando usuário não existe', () async {
      // Arrange
      final user = User(
        id: faker.guid.guid(),
        email: faker.internet.email(),
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: false,
      );

      when(mockCollection.doc(user.id)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false); // User doesn't exist

      // Act & Assert
      expect(
        () => repository.updateUser(user),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('FirebaseUserRepository - userExists', () {
    test('deve retornar true quando usuário existe', () async {
      // Arrange
      final userId = faker.guid.guid();

      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);

      // Act
      final result = await repository.userExists(userId);

      // Assert
      expect(result, isTrue);
    });

    test('deve retornar false quando usuário não existe', () async {
      // Arrange
      final userId = faker.guid.guid();

      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.userExists(userId);

      // Assert
      expect(result, isFalse);
    });

    test('deve lançar ValidationException quando userId está vazio', () async {
      // Act & Assert
      expect(
        () => repository.userExists(''),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
