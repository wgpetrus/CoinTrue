# 8. Testing

## Table of Contents

1. [Testing Pyramid](#1-testing-pyramid)
2. [Unit Testing](#2-unit-testing)
3. [Widget Testing](#3-widget-testing)
4. [Integration Testing](#4-integration-testing)
5. [Testable Architecture](#5-testable-architecture)
6. [Mocking and Dependency Injection](#6-mocking-and-dependency-injection)
7. [Continuous Testing](#7-continuous-testing)

---

## 1. Testing Pyramid

```
         ┌─────────────┐
        ╱               ╲
       ╱   Integration   ╲      ← Few, slow, expensive
      ╱      Tests        ╲       (E2E, full system)
     ╱─────────────────────╲
    ╱                       ╲
   ╱     Widget Tests        ╲   ← More, faster
  ╱    (Component Tests)      ╲    (UI components)
 ╱─────────────────────────────╲
╱                               ╲
╱         Unit Tests             ╲  ← Many, fast, cheap
╱      (Business Logic)           ╲   (Functions, classes)
─────────────────────────────────────
```

**Distribution**:
- **70%** Unit Tests
- **20%** Widget Tests
- **10%** Integration Tests

<!-- AI_NOTE: Write more unit tests than integration tests. Unit tests are fast, reliable, and easy to maintain. Integration tests are slow and brittle. -->

---

## 2. Unit Testing

### 2.1 What to Test

**Test**:
- Business logic
- Data transformations
- Validation logic
- Calculations
- Edge cases and error handling

**Don't Test**:
- Framework code
- Third-party libraries
- Trivial getters/setters

---

### 2.2 Unit Test Example

```dart
// Class to test
class Calculator {
  int add(int a, int b) => a + b;
  
  int divide(int a, int b) {
    if (b == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return a ~/ b;
  }
}

// Test file: calculator_test.dart
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;
    
    setUp(() {
      calculator = Calculator();
    });
    
    test('add returns sum of two numbers', () {
      expect(calculator.add(2, 3), equals(5));
      expect(calculator.add(-1, 1), equals(0));
      expect(calculator.add(0, 0), equals(0));
    });
    
    test('divide returns quotient', () {
      expect(calculator.divide(10, 2), equals(5));
      expect(calculator.divide(7, 2), equals(3));
    });
    
    test('divide throws error when dividing by zero', () {
      expect(
        () => calculator.divide(10, 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

---

### 2.3 Testing ViewModels

```dart
// ViewModel to test
class CounterViewModel extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
}

// Test file: counter_viewmodel_test.dart
import 'package:test/test.dart';

void main() {
  group('CounterViewModel', () {
    late CounterViewModel viewModel;
    
    setUp(() {
      viewModel = CounterViewModel();
    });
    
    test('initial count is 0', () {
      expect(viewModel.count, equals(0));
    });
    
    test('increment increases count', () {
      viewModel.increment();
      expect(viewModel.count, equals(1));
      
      viewModel.increment();
      expect(viewModel.count, equals(2));
    });
    
    test('decrement decreases count', () {
      viewModel.increment();
      viewModel.increment();
      viewModel.decrement();
      
      expect(viewModel.count, equals(1));
    });
    
    test('notifies listeners on increment', () {
      var notified = false;
      viewModel.addListener(() {
        notified = true;
      });
      
      viewModel.increment();
      expect(notified, isTrue);
    });
  });
}
```

---

## 3. Widget Testing

### 3.1 What to Test

**Test**:
- Widget rendering
- User interactions
- State changes
- Navigation
- Form validation

---

### 3.2 Widget Test Example

```dart
// Widget to test
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count', key: Key('counter_text')),
        ElevatedButton(
          key: Key('increment_button'),
          onPressed: () {
            setState(() {
              _count++;
            });
          },
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// Test file: counter_widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterWidget', () {
    testWidgets('displays initial count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CounterWidget())),
      );
      
      expect(find.text('Count: 0'), findsOneWidget);
    });
    
    testWidgets('increments count on button press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CounterWidget())),
      );
      
      // Tap the button
      await tester.tap(find.byKey(Key('increment_button')));
      await tester.pump(); // Rebuild widget
      
      expect(find.text('Count: 1'), findsOneWidget);
      
      // Tap again
      await tester.tap(find.byKey(Key('increment_button')));
      await tester.pump();
      
      expect(find.text('Count: 2'), findsOneWidget);
    });
    
    testWidgets('button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CounterWidget())),
      );
      
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Increment'), findsOneWidget);
    });
  });
}
```

---

### 3.3 Testing Forms

```dart
// Form widget
class LoginForm extends StatefulWidget {
  final Function(String email, String password) onSubmit;
  
  LoginForm({required this.onSubmit});
  
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: Key('email_field'),
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
          ),
          TextFormField(
            key: Key('password_field'),
            controller: _passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          ElevatedButton(
            key: Key('submit_button'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _emailController.text,
                  _passwordController.text,
                );
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}

// Test file
void main() {
  group('LoginForm', () {
    testWidgets('shows validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(onSubmit: (email, password) {}),
          ),
        ),
      );
      
      // Tap submit without entering data
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pump();
      
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
    
    testWidgets('submits valid form', (WidgetTester tester) async {
      String? submittedEmail;
      String? submittedPassword;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onSubmit: (email, password) {
                submittedEmail = email;
                submittedPassword = password;
              },
            ),
          ),
        ),
      );
      
      // Enter valid data
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      
      // Submit
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pump();
      
      expect(submittedEmail, equals('test@example.com'));
      expect(submittedPassword, equals('password123'));
    });
  });
}
```

---

## 4. Integration Testing

### 4.1 What to Test

**Test**:
- Complete user flows
- Navigation between screens
- API integration
- Database operations
- End-to-end scenarios

---

### 4.2 Integration Test Example

```dart
// test_driver/app.dart
import 'package:flutter_driver/driver_extension.dart';
import 'package:my_app/main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}

// test_driver/app_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Login Flow', () {
    late FlutterDriver driver;
    
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    
    tearDownAll(() async {
      await driver.close();
    });
    
    test('complete login flow', () async {
      // Find widgets
      final emailField = find.byValueKey('email_field');
      final passwordField = find.byValueKey('password_field');
      final loginButton = find.byValueKey('login_button');
      
      // Enter credentials
      await driver.tap(emailField);
      await driver.enterText('test@example.com');
      
      await driver.tap(passwordField);
      await driver.enterText('password123');
      
      // Submit
      await driver.tap(loginButton);
      
      // Wait for navigation
      await driver.waitFor(find.text('Welcome'));
      
      // Verify we're on home screen
      expect(await driver.getText(find.text('Welcome')), 'Welcome');
    });
  });
}
```

---

## 5. Testable Architecture

### 5.1 Dependency Injection

**Makes testing easier by allowing mock dependencies**:

```dart
// ❌ Bad - Hard to test
class UserViewModel {
  Future<void> loadUser() async {
    // Directly uses Firebase - can't test without Firebase
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc('123')
        .get();
  }
}

// ✅ Good - Testable with dependency injection
class UserViewModel {
  final UserRepository _repository;
  
  UserViewModel(this._repository); // Inject dependency
  
  Future<void> loadUser() async {
    final user = await _repository.getUser('123');
    // Can inject mock repository for testing
  }
}
```

---

### 5.2 Interface-Based Design

```dart
// Define interface
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
}

// Production implementation
class FirebaseUserRepository implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    // Real Firebase call
  }
  
  @override
  Future<void> saveUser(User user) async {
    // Real Firebase call
  }
}

// Test implementation
class MockUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  
  @override
  Future<User> getUser(String id) async {
    return _users[id] ?? throw Exception('User not found');
  }
  
  @override
  Future<void> saveUser(User user) async {
    _users[user.id] = user;
  }
}
```

---

## 6. Mocking and Dependency Injection

### 6.1 Using Mockito

```dart
// pubspec.yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0

// Generate mocks
// Run: flutter pub run build_runner build

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Annotate classes to generate mocks
@GenerateMocks([UserRepository, AuthService])
void main() {}

// This generates: user_repository.mocks.dart

// Test file
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'user_repository.mocks.dart';

void main() {
  group('UserViewModel', () {
    late MockUserRepository mockRepository;
    late UserViewModel viewModel;
    
    setUp(() {
      mockRepository = MockUserRepository();
      viewModel = UserViewModel(mockRepository);
    });
    
    test('loadUser fetches user from repository', () async {
      // Arrange
      final user = User(id: '123', name: 'John', email: 'john@example.com');
      when(mockRepository.getUser('123'))
          .thenAnswer((_) async => user);
      
      // Act
      await viewModel.loadUser('123');
      
      // Assert
      expect(viewModel.user, equals(user));
      verify(mockRepository.getUser('123')).called(1);
    });
    
    test('loadUser handles errors', () async {
      // Arrange
      when(mockRepository.getUser('123'))
          .thenThrow(Exception('User not found'));
      
      // Act
      await viewModel.loadUser('123');
      
      // Assert
      expect(viewModel.error, isNotNull);
      expect(viewModel.user, isNull);
    });
  });
}
```

---

### 6.2 Manual Mocks

```dart
// Simple mock without code generation
class MockUserRepository implements UserRepository {
  User? userToReturn;
  Exception? exceptionToThrow;
  int getUserCallCount = 0;
  
  @override
  Future<User> getUser(String id) async {
    getUserCallCount++;
    
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    
    if (userToReturn != null) {
      return userToReturn!;
    }
    
    throw Exception('User not found');
  }
  
  @override
  Future<void> saveUser(User user) async {
    // Mock implementation
  }
}

// Usage in tests
void main() {
  test('loadUser success', () async {
    final mockRepo = MockUserRepository();
    mockRepo.userToReturn = User(id: '123', name: 'John', email: 'john@example.com');
    
    final viewModel = UserViewModel(mockRepo);
    await viewModel.loadUser('123');
    
    expect(viewModel.user, isNotNull);
    expect(mockRepo.getUserCallCount, equals(1));
  });
}
```

---

### 6.3 Dependency Injection with Provider

```dart
// Setup for testing with Provider
void main() {
  testWidgets('UserProfileScreen displays user', (WidgetTester tester) async {
    // Create mock repository
    final mockRepo = MockUserRepository();
    mockRepo.userToReturn = User(id: '123', name: 'John', email: 'john@example.com');
    
    // Provide mock to widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<UserRepository>(
          create: (_) => mockRepo,
          child: UserProfileScreen(),
        ),
      ),
    );
    
    // Wait for async operations
    await tester.pumpAndSettle();
    
    // Verify
    expect(find.text('John'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });
}
```

---

## 7. Continuous Testing

### 7.1 Test Coverage

```yaml
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

**Coverage Goals**:
- **Unit Tests**: 80%+ coverage
- **Widget Tests**: 60%+ coverage
- **Integration Tests**: Critical paths covered

---

### 7.2 CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%: $COVERAGE%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

### 7.3 Test Organization

```
test/
├── unit/
│   ├── models/
│   │   └── user_test.dart
│   ├── services/
│   │   └── auth_service_test.dart
│   └── viewmodels/
│       └── login_viewmodel_test.dart
│
├── widget/
│   ├── screens/
│   │   └── login_screen_test.dart
│   └── widgets/
│       └── custom_button_test.dart
│
├── integration/
│   └── login_flow_test.dart
│
└── helpers/
    ├── mock_repositories.dart
    └── test_helpers.dart
```

---

### 7.4 Test Helpers

```dart
// test/helpers/test_helpers.dart

// Create test user
User createTestUser({
  String id = '123',
  String name = 'Test User',
  String email = 'test@example.com',
}) {
  return User(id: id, name: name, email: email);
}

// Pump widget with providers
Future<void> pumpWidgetWithProviders(
  WidgetTester tester,
  Widget widget, {
  UserRepository? userRepository,
  AuthService? authService,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<UserRepository>(
            create: (_) => userRepository ?? MockUserRepository(),
          ),
          Provider<AuthService>(
            create: (_) => authService ?? MockAuthService(),
          ),
        ],
        child: widget,
      ),
    ),
  );
}

// Wait for async operations
Future<void> waitForAsync(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await Future.delayed(Duration(milliseconds: 100));
  await tester.pump();
}
```

---

### 7.5 AI Testing Notes

<!-- AI_NOTE: When generating code, always consider testability:
1. Use dependency injection
2. Avoid static methods and singletons
3. Keep functions pure when possible
4. Separate business logic from UI
5. Use interfaces for external dependencies

When writing tests:
1. Follow AAA pattern (Arrange, Act, Assert)
2. Test one thing per test
3. Use descriptive test names
4. Mock external dependencies
5. Test edge cases and error scenarios
-->

---

### 7.6 Testing Best Practices

**DO**:
- Write tests before or alongside code (TDD)
- Test behavior, not implementation
- Keep tests simple and focused
- Use descriptive test names
- Test edge cases and errors
- Mock external dependencies
- Run tests frequently

**DON'T**:
- Test framework code
- Test third-party libraries
- Write brittle tests that break easily
- Test implementation details
- Skip error cases
- Have tests depend on each other
- Ignore failing tests

---

### 7.7 Test Examples Summary

```dart
// Unit Test Example
test('calculator adds two numbers', () {
  final calculator = Calculator();
  expect(calculator.add(2, 3), equals(5));
});

// Widget Test Example
testWidgets('button displays text', (tester) async {
  await tester.pumpWidget(MyButton());
  expect(find.text('Click Me'), findsOneWidget);
});

// Integration Test Example
test('complete user flow', () async {
  await driver.tap(find.byValueKey('login_button'));
  await driver.waitFor(find.text('Welcome'));
});

// Mock Example
when(mockRepo.getUser('123'))
    .thenAnswer((_) async => testUser);
```

---

*Last Updated: November 2025*  
*End of Architecture Documentation*

---

## Summary

This architecture documentation provides:

1. **Design Principles**: SOLID, DRY, KISS, YAGNI
2. **Architectural Patterns**: MVC, MVVM, Clean Architecture
3. **System Design**: Scalability, databases, communication
4. **Backend Architecture**: Layers, API design, authentication
5. **Cloud Platforms**: Firebase, AWS, GCP comparison
6. **DevOps**: Git workflow, CI/CD, monitoring
7. **Security**: Authentication, encryption, vulnerabilities
8. **Testing**: Unit, widget, integration tests

Use this as a reference for all architectural decisions in your Flutter projects.
