# 1. Design and Architecture

---

## ⭐ PADRÃO DA EMPRESA: MVC

**IMPORTANTE**: A empresa onde Petrus trabalha usa **MVC (Model-View-Controller) em TODOS os projetos**.

📋 **Ver detalhes completos em**: [COMPANY_STANDARDS.md](./COMPANY_STANDARDS.md)

**Resumo**:
- ✅ **Model**: Dados e entidades (`lib/models/`)
- ✅ **View**: UI e widgets (`lib/views/`)
- ✅ **Controller**: Lógica e state (`lib/controllers/`)
- ✅ **State Management**: Provider (ChangeNotifier)

**O restante deste documento serve como referência técnica complementar** sobre princípios de engenharia, padrões de design, e boas práticas que se aplicam independente da arquitetura.

---

## Table of Contents

1. [Core Engineering Principles](#1-core-engineering-principles)
2. [Architectural Patterns](#2-architectural-patterns) *(Referência - Use MVC da empresa)*
3. [SOLID Principles in Flutter](#3-solid-principles-in-flutter)
4. [Design Patterns](#4-design-patterns)
5. [State Management](#5-state-management) *(Referência - Use Provider)*
6. [Folder Structure](#6-folder-structure) *(Referência - Use estrutura da empresa)*
7. [Anti-Patterns](#7-anti-patterns)

---

## 1. Core Engineering Principles

### 1.1 Separation of Concerns (SoC)

**Definition**: Each module or class should have a single, well-defined responsibility.

**Why it matters**: 
- Easier to understand, test, and maintain
- Changes in one area don't cascade to others
- Enables parallel development

<!-- AI_NOTE: When generating code, ensure each class/file has a clear, singular purpose. If a class is doing multiple unrelated things, split it. -->

#### ✅ Good Example (Flutter)

```dart
// Separate concerns: UI, Business Logic, Data
class UserProfileScreen extends StatelessWidget {
  final UserProfileViewModel viewModel;
  
  const UserProfileScreen({required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    // Only handles UI rendering
    return Scaffold(
      body: UserProfileView(user: viewModel.user),
    );
  }
}

class UserProfileViewModel {
  final UserRepository _repository;
  User? user;
  
  UserProfileViewModel(this._repository);
  
  // Only handles business logic
  Future<void> loadUser(String userId) async {
    user = await _repository.getUser(userId);
  }
}

class UserRepository {
  final ApiClient _apiClient;
  
  UserRepository(this._apiClient);
  
  // Only handles data access
  Future<User> getUser(String userId) async {
    return await _apiClient.fetchUser(userId);
  }
}
```

#### ❌ Bad Example

```dart
// Everything mixed together - UI, logic, and data access
class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? user;
  
  @override
  void initState() {
    super.initState();
    // Business logic in UI layer
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    // Direct API call from UI - tight coupling
    final response = await http.get(Uri.parse('https://api.example.com/user/123'));
    setState(() {
      user = User.fromJson(jsonDecode(response.body));
    });
  }

  
  @override
  Widget build(BuildContext context) {
    // UI rendering mixed with null checks and logic
    if (user == null) return CircularProgressIndicator();
    return Text(user!.name);
  }
}
```

---

### 1.2 DRY (Don't Repeat Yourself)

**Definition**: Every piece of knowledge should have a single, unambiguous representation.

**Why it matters**:
- Reduces maintenance burden
- Single source of truth
- Easier to update and fix bugs

<!-- AI_NOTE: Look for repeated code patterns and extract them into reusable functions/classes. But don't over-abstract - some duplication is acceptable if it improves clarity. -->

#### ✅ Good Example

```dart
// Reusable validation logic
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}


// Used in multiple forms
class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: Validators.validateEmail,
      decoration: InputDecoration(labelText: 'Email'),
    );
  }
}
```

#### ❌ Bad Example

```dart
// Validation logic duplicated in every form
class LoginForm extends StatelessWidget {
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }
}

class SignupForm extends StatelessWidget {
  String? _validateEmail(String? value) {
    // Same logic repeated - maintenance nightmare
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }
}
```

---

### 1.3 KISS (Keep It Simple, Stupid)

**Definition**: Systems work best when they're kept simple rather than made complex.

**Why it matters**:
- Easier to understand and maintain
- Fewer bugs
- Faster development

<!-- AI_NOTE: Prefer straightforward solutions. Don't add abstraction layers or patterns unless they solve a real problem. -->


#### ✅ Good Example

```dart
class PriceCalculator {
  double calculateTotal(List<Item> items) {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }
}
```

#### ❌ Bad Example

```dart
// Over-engineered for a simple task
abstract class IPriceCalculationStrategy {
  double calculate(List<Item> items);
}

class SimplePriceCalculationStrategy implements IPriceCalculationStrategy {
  @override
  double calculate(List<Item> items) {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }
}

class PriceCalculatorFactory {
  static IPriceCalculationStrategy create(CalculationType type) {
    switch (type) {
      case CalculationType.simple:
        return SimplePriceCalculationStrategy();
      default:
        throw UnimplementedError();
    }
  }
}

// Just to add numbers together!
```

---

### 1.4 YAGNI (You Aren't Gonna Need It)

**Definition**: Don't add functionality until it's actually needed.

**Why it matters**:
- Reduces code bloat
- Faster initial development
- Less maintenance burden


<!-- AI_NOTE: Build what's needed now. Don't add "future-proofing" features that aren't in the requirements. -->

#### ✅ Good Example

```dart
// Simple user model with only needed fields
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}
```

#### ❌ Bad Example

```dart
// Over-engineered with features "we might need someday"
class User {
  final String id;
  final String name;
  final String email;
  final String? middleName; // Not in requirements
  final String? nickname; // Not in requirements
  final List<String>? alternateEmails; // Not in requirements
  final Map<String, dynamic>? metadata; // "For future flexibility"
  final DateTime? lastLoginAt; // Not needed yet
  final int loginCount; // Not needed yet
  final UserPreferences? preferences; // Not in requirements
  
  // Complex constructor for features we don't use
  User({
    required this.id,
    required this.name,
    required this.email,
    this.middleName,
    this.nickname,
    this.alternateEmails,
    this.metadata,
    this.lastLoginAt,
    this.loginCount = 0,
    this.preferences,
  });
}
```

---

### 1.5 Coupling and Cohesion

**Coupling**: The degree of interdependence between modules.  
**Cohesion**: How closely related the responsibilities of a module are.

**Goal**: **Low Coupling, High Cohesion**

<!-- AI_NOTE: Modules should be independent (low coupling) but internally focused (high cohesion). Changes in one module shouldn't require changes in others. -->

#### ✅ Good Example (Low Coupling, High Cohesion)

```dart
// High cohesion - all methods relate to user authentication
class AuthService {
  Future<User> login(String email, String password) async { /* ... */ }
  Future<void> logout() async { /* ... */ }
  Future<User> getCurrentUser() async { /* ... */ }
  Future<void> resetPassword(String email) async { /* ... */ }
}

// Low coupling - depends on abstraction, not concrete implementation
class UserProfileViewModel {
  final AuthService _authService; // Could be swapped with different implementation
  
  UserProfileViewModel(this._authService);
  
  Future<void> loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    // ...
  }
}
```

#### ❌ Bad Example (High Coupling, Low Cohesion)

```dart
// Low cohesion - unrelated responsibilities mixed together
class UserService {
  Future<User> login(String email, String password) async { /* ... */ }
  Future<void> sendEmail(String to, String subject) async { /* ... */ }
  Future<List<Product>> getProducts() async { /* ... */ }
  Future<void> logAnalytics(String event) async { /* ... */ }
}


// High coupling - directly depends on concrete Firebase implementation
class UserProfileViewModel {
  Future<void> loadCurrentUser() async {
    // Tightly coupled to Firebase - can't test or swap implementations
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    // ...
  }
}
```

---

## 2. Architectural Patterns

### ⭐ 2.1 MVC (Model-View-Controller) - PADRÃO DA EMPRESA

**Structure**:
- **Model**: Data and business logic
- **View**: UI presentation
- **Controller**: Handles user input, updates model and view

**✅ A EMPRESA USA MVC EM TODOS OS PROJETOS**

Ver implementação completa e estrutura de pastas em: [COMPANY_STANDARDS.md](./COMPANY_STANDARDS.md)

**Implementação com Provider (padrão da empresa)**:

```dart
// Model (lib/models/user.dart)
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );
}

// Controller (lib/controllers/user_controller.dart)
class UserController extends ChangeNotifier {
  final UserService _service;
  
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  
  UserController(this._service);
  
  Future<void> loadUser(String id) async {
    _isLoading = true;
    notifyListeners();
    
    _user = await _service.getUser(id);
    
    _isLoading = false;
    notifyListeners();
  }
}

// View (lib/views/screens/user_screen.dart)
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    
    if (controller.isLoading) {
      return CircularProgressIndicator();
    }
    
    return Text(controller.user?.name ?? 'No user');
  }
}
```

**Pros**: Simple, well-understood, padrão da empresa  
**Cons**: Controller can become bloated (mitigar com services)

---

### 2.2 MVVM (Model-View-ViewModel) - REFERÊNCIA

**⚠️ Nota**: A empresa usa MVC. Esta seção é apenas referência técnica.

### 2.2 MVVM (Model-View-ViewModel)

**Structure**:
- **Model**: Data and business logic
- **View**: UI presentation (passive)
- **ViewModel**: Exposes data streams, handles presentation logic

**When to use**: Flutter apps with reactive state management (Provider, Riverpod, BLoC).

**Pros**: Clear separation, testable, reactive  
**Cons**: More boilerplate, learning curve

<!-- AI_NOTE: MVVM is the recommended pattern for Flutter apps. ViewModel should expose streams/notifiers that the View observes. -->

```dart
// Model
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// ViewModel
class UserProfileViewModel extends ChangeNotifier {
  final UserRepository _repository;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  UserProfileViewModel(this._repository);
  
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _repository.getUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


// View
class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileViewModel(context.read<UserRepository>()),
      child: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }
          
          final user = viewModel.user;
          if (user == null) {
            return Center(child: Text('No user found'));
          }
          
          return Column(
            children: [
              Text(user.name),
              Text(user.email),
            ],
          );
        },
      ),
    );
  }
}
```

---

### 2.3 Clean Architecture - REFERÊNCIA

**⚠️ Nota**: A empresa usa MVC. Esta seção é apenas referência técnica.

**Structure** (Layers from outer to inner):
1. **Presentation Layer**: UI, ViewModels, Widgets
2. **Domain Layer**: Business logic, Use Cases, Entities
3. **Data Layer**: Repositories, Data Sources, DTOs

**Dependency Rule**: Inner layers don't know about outer layers.

**When to use**: Large, complex applications that need to be maintainable long-term.

**Pros**: Highly testable, independent of frameworks, scalable  
**Cons**: More boilerplate, steeper learning curve


<!-- AI_NOTE: In Clean Architecture, dependencies point inward. Domain layer is pure Dart with no Flutter dependencies. Data and Presentation depend on Domain. -->

```dart
// DOMAIN LAYER - Pure business logic, no dependencies

// Entity
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// Repository Interface (abstraction)
abstract class UserRepository {
  Future<User> getUser(String userId);
  Future<void> updateUser(User user);
}

// Use Case
class GetUserUseCase {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  Future<User> execute(String userId) {
    return repository.getUser(userId);
  }
}

// DATA LAYER - Implements domain interfaces

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  
  UserRepositoryImpl(this.remoteDataSource, this.localDataSource);
  
  @override
  Future<User> getUser(String userId) async {
    try {
      final userDto = await remoteDataSource.fetchUser(userId);
      final user = userDto.toEntity();
      await localDataSource.cacheUser(user);
      return user;
    } catch (e) {
      return await localDataSource.getCachedUser(userId);
    }
  }
  
  @override
  Future<void> updateUser(User user) async {
    await remoteDataSource.updateUser(UserDto.fromEntity(user));
  }
}


// PRESENTATION LAYER - UI and ViewModels

class UserProfileViewModel extends ChangeNotifier {
  final GetUserUseCase getUserUseCase;
  
  User? user;
  bool isLoading = false;
  
  UserProfileViewModel(this.getUserUseCase);
  
  Future<void> loadUser(String userId) async {
    isLoading = true;
    notifyListeners();
    
    user = await getUserUseCase.execute(userId);
    
    isLoading = false;
    notifyListeners();
  }
}
```

---

## 3. SOLID Principles in Flutter

### 3.1 Single Responsibility Principle (SRP)

**Definition**: A class should have only one reason to change.

<!-- AI_NOTE: Each class should do one thing well. If you're using "and" to describe what a class does, it probably violates SRP. -->

#### ✅ Good Example

```dart
// Each class has a single responsibility

class UserValidator {
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class UserRepository {
  Future<User> getUser(String id) async {
    // Only handles data access
  }
}

class UserNotificationService {
  Future<void> sendWelcomeEmail(User user) async {
    // Only handles notifications
  }
}
```


#### ❌ Bad Example

```dart
// God class - does everything
class UserManager {
  bool isValidEmail(String email) { /* ... */ }
  Future<User> getUser(String id) async { /* ... */ }
  Future<void> saveUser(User user) async { /* ... */ }
  Future<void> sendWelcomeEmail(User user) async { /* ... */ }
  Future<void> logUserActivity(String activity) async { /* ... */ }
  Widget buildUserProfile(User user) { /* ... */ }
}
```

---

### 3.2 Open/Closed Principle (OCP)

**Definition**: Classes should be open for extension but closed for modification.

<!-- AI_NOTE: Use abstraction and polymorphism to add new functionality without changing existing code. -->

#### ✅ Good Example

```dart
// Abstract base - closed for modification
abstract class PaymentProcessor {
  Future<PaymentResult> processPayment(double amount);
}

// Extended with new implementations - open for extension
class CreditCardProcessor implements PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount) async {
    // Credit card logic
    return PaymentResult.success();
  }
}

class PayPalProcessor implements PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount) async {
    // PayPal logic
    return PaymentResult.success();
  }
}

// Can add new payment methods without modifying existing code
class CryptoProcessor implements PaymentProcessor {
  @override
  Future<PaymentResult> processPayment(double amount) async {
    // Crypto logic
    return PaymentResult.success();
  }
}
```


#### ❌ Bad Example

```dart
// Must modify this class every time we add a payment method
class PaymentProcessor {
  Future<PaymentResult> processPayment(String method, double amount) async {
    if (method == 'credit_card') {
      // Credit card logic
    } else if (method == 'paypal') {
      // PayPal logic
    } else if (method == 'crypto') {
      // Have to modify existing class to add new method
    }
    return PaymentResult.success();
  }
}
```

---

### 3.3 Liskov Substitution Principle (LSP)

**Definition**: Objects of a superclass should be replaceable with objects of a subclass without breaking the application.

<!-- AI_NOTE: Subclasses must honor the contract of their parent class. Don't throw unexpected exceptions or change expected behavior. -->

#### ✅ Good Example

```dart
abstract class Bird {
  void eat();
  void sleep();
}

class Sparrow extends Bird {
  @override
  void eat() => print('Sparrow eating');
  
  @override
  void sleep() => print('Sparrow sleeping');
}

class Penguin extends Bird {
  @override
  void eat() => print('Penguin eating');
  
  @override
  void sleep() => print('Penguin sleeping');
}

// Both can be used interchangeably
void feedBird(Bird bird) {
  bird.eat(); // Works for any Bird subclass
}
```


#### ❌ Bad Example

```dart
abstract class Bird {
  void fly();
}

class Sparrow extends Bird {
  @override
  void fly() => print('Sparrow flying');
}

class Penguin extends Bird {
  @override
  void fly() {
    // Violates LSP - penguins can't fly!
    throw UnsupportedError('Penguins cannot fly');
  }
}

// This breaks when we pass a Penguin
void makeBirdFly(Bird bird) {
  bird.fly(); // Crashes if bird is a Penguin
}
```

**Better Design**:

```dart
abstract class Bird {
  void eat();
}

abstract class FlyingBird extends Bird {
  void fly();
}

class Sparrow extends FlyingBird {
  @override
  void eat() => print('Eating');
  
  @override
  void fly() => print('Flying');
}

class Penguin extends Bird {
  @override
  void eat() => print('Eating');
  
  void swim() => print('Swimming');
}
```

---

### 3.4 Interface Segregation Principle (ISP)

**Definition**: Clients should not be forced to depend on interfaces they don't use.

<!-- AI_NOTE: Create small, focused interfaces rather than large, monolithic ones. -->


#### ✅ Good Example

```dart
// Small, focused interfaces
abstract class Readable {
  Future<String> read();
}

abstract class Writable {
  Future<void> write(String data);
}

abstract class Deletable {
  Future<void> delete();
}

// Implement only what you need
class ReadOnlyFile implements Readable {
  @override
  Future<String> read() async {
    // Read implementation
    return 'data';
  }
}

class ReadWriteFile implements Readable, Writable {
  @override
  Future<String> read() async => 'data';
  
  @override
  Future<void> write(String data) async {
    // Write implementation
  }
}
```

#### ❌ Bad Example

```dart
// Fat interface - forces implementation of unused methods
abstract class FileOperations {
  Future<String> read();
  Future<void> write(String data);
  Future<void> delete();
  Future<void> compress();
  Future<void> encrypt();
}

// Forced to implement methods we don't need
class ReadOnlyFile implements FileOperations {
  @override
  Future<String> read() async => 'data';
  
  @override
  Future<void> write(String data) async {
    throw UnsupportedError('Read-only file');
  }
  
  @override
  Future<void> delete() async {
    throw UnsupportedError('Cannot delete');
  }
  
  @override
  Future<void> compress() async {
    throw UnsupportedError('Cannot compress');
  }
  
  @override
  Future<void> encrypt() async {
    throw UnsupportedError('Cannot encrypt');
  }
}
```

---

### 3.5 Dependency Inversion Principle (DIP)

**Definition**: High-level modules should not depend on low-level modules. Both should depend on abstractions.

<!-- AI_NOTE: Depend on interfaces/abstract classes, not concrete implementations. This enables testing and flexibility. -->

#### ✅ Good Example

```dart
// Abstraction
abstract class UserRepository {
  Future<User> getUser(String id);
}

// High-level module depends on abstraction
class UserProfileViewModel {
  final UserRepository _repository; // Depends on abstraction
  
  UserProfileViewModel(this._repository);
  
  Future<void> loadUser(String id) async {
    final user = await _repository.getUser(id);
    // ...
  }
}

// Low-level implementations
class FirebaseUserRepository implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    // Firebase implementation
    return User(id: id, name: 'John', email: 'john@example.com');
  }
}

class ApiUserRepository implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    // REST API implementation
    return User(id: id, name: 'John', email: 'john@example.com');
  }
}

// Easy to swap implementations or mock for testing
void main() {
  final viewModel = UserProfileViewModel(FirebaseUserRepository());
  // or
  final testViewModel = UserProfileViewModel(MockUserRepository());
}
```


#### ❌ Bad Example

```dart
// High-level module directly depends on low-level concrete implementation
class UserProfileViewModel {
  Future<void> loadUser(String id) async {
    // Tightly coupled to Firebase - can't test or swap
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
    
    final user = User.fromJson(doc.data()!);
    // ...
  }
}
```

---

## 4. Design Patterns

### 4.1 Factory Pattern

**Purpose**: Create objects without specifying the exact class.

**When to use**: When object creation logic is complex or when you need to return different types based on input.

```dart
abstract class DatabaseService {
  Future<void> connect();
  Future<Map<String, dynamic>> query(String sql);
}

class PostgresService implements DatabaseService {
  @override
  Future<void> connect() async => print('Connecting to Postgres');
  
  @override
  Future<Map<String, dynamic>> query(String sql) async => {};
}

class MongoService implements DatabaseService {
  @override
  Future<void> connect() async => print('Connecting to MongoDB');
  
  @override
  Future<Map<String, dynamic>> query(String sql) async => {};
}

// Factory
class DatabaseFactory {
  static DatabaseService create(String type) {
    switch (type) {
      case 'postgres':
        return PostgresService();
      case 'mongo':
        return MongoService();
      default:
        throw ArgumentError('Unknown database type: $type');
    }
  }
}

// Usage
final db = DatabaseFactory.create('postgres');
await db.connect();
```

---

### 4.2 Repository Pattern

**Purpose**: Abstraction layer between data sources and business logic.

**When to use**: Always, in any app that accesses data.

<!-- AI_NOTE: Repository pattern is essential in Flutter. It decouples data access from business logic and makes testing easy. -->

```dart
// Domain entity
class Product {
  final String id;
  final String name;
  final double price;
  
  Product({required this.id, required this.name, required this.price});
}

// Repository interface
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<void> saveProduct(Product product);
}

// Implementation
class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  
  ProductRepositoryImpl(this._apiClient, this._localDb);
  
  @override
  Future<List<Product>> getProducts() async {
    try {
      // Try remote first
      final products = await _apiClient.fetchProducts();
      // Cache locally
      await _localDb.saveProducts(products);
      return products;
    } catch (e) {
      // Fallback to cache
      return await _localDb.getProducts();
    }
  }
  
  @override
  Future<Product> getProduct(String id) async {
    return await _apiClient.fetchProduct(id);
  }
  
  @override
  Future<void> saveProduct(Product product) async {
    await _apiClient.updateProduct(product);
    await _localDb.saveProduct(product);
  }
}
```

---

### 4.3 Singleton Pattern

**Purpose**: Ensure a class has only one instance.

**When to use**: For shared resources like database connections, loggers, or configuration.

**Caution**: Can make testing difficult. Use dependency injection when possible.

```dart
class Logger {
  static final Logger _instance = Logger._internal();
  
  factory Logger() {
    return _instance;
  }
  
  Logger._internal();
  
  void log(String message) {
    print('[LOG] $message');
  }
}

// Usage - always returns the same instance
final logger1 = Logger();
final logger2 = Logger();
// logger1 == logger2 is true
```

**Better approach with dependency injection**:

```dart
class Logger {
  void log(String message) {
    print('[LOG] $message');
  }
}

// Provide as singleton through DI
void main() {
  runApp(
    Provider<Logger>(
      create: (_) => Logger(), // Single instance
      child: MyApp(),
    ),
  );
}

// Access anywhere
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logger = context.read<Logger>();
    logger.log('Widget built');
    return Container();
  }
}
```

---

### 4.4 Observer Pattern

**Purpose**: Define a one-to-many dependency where observers are notified of state changes.

**When to use**: State management in Flutter (ChangeNotifier, Streams, BLoC).

```dart
// Subject
class StockPrice extends ChangeNotifier {
  double _price = 0.0;
  
  double get price => _price;
  
  void updatePrice(double newPrice) {
    _price = newPrice;
    notifyListeners(); // Notify all observers
  }
}

// Observer (Widget)
class StockPriceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StockPrice(),
      child: Consumer<StockPrice>(
        builder: (context, stock, _) {
          return Text('Price: \$${stock.price}');
        },
      ),
    );
  }
}
```

---

### 4.5 Strategy Pattern

**Purpose**: Define a family of algorithms and make them interchangeable.

**When to use**: When you have multiple ways to perform an operation.

```dart
// Strategy interface
abstract class SortStrategy {
  List<int> sort(List<int> data);
}

// Concrete strategies
class BubbleSortStrategy implements SortStrategy {
  @override
  List<int> sort(List<int> data) {
    // Bubble sort implementation
    return data..sort();
  }
}

class QuickSortStrategy implements SortStrategy {
  @override
  List<int> sort(List<int> data) {
    // Quick sort implementation
    return data..sort();
  }
}

// Context
class DataSorter {
  SortStrategy _strategy;
  
  DataSorter(this._strategy);
  
  void setStrategy(SortStrategy strategy) {
    _strategy = strategy;
  }
  
  List<int> sortData(List<int> data) {
    return _strategy.sort(data);
  }
}

// Usage
final sorter = DataSorter(BubbleSortStrategy());
final sorted = sorter.sortData([3, 1, 4, 1, 5]);

// Change strategy at runtime
sorter.setStrategy(QuickSortStrategy());
```

---

## 5. State Management

### ⭐ PADRÃO DA EMPRESA: Provider

**A empresa usa Provider (ChangeNotifier) em todos os projetos.**

Ver implementação completa em: [COMPANY_STANDARDS.md](./COMPANY_STANDARDS.md)

### 5.1 Comparison Table (Referência)

| Solution | Complexity | Learning Curve | Use Case | Boilerplate |
|----------|-----------|----------------|----------|-------------|
| **Provider** ⭐ | Medium | Moderate | **Padrão da empresa** | Low |
| **setState** | Low | Easy | Simple, local state | Minimal |
| **Riverpod** | Medium | Moderate | Modern Provider alternative | Low |
| **BLoC** | High | Steep | Complex apps, strict separation | High |
| **GetX** | Low | Easy | Rapid development | Minimal |

**⚠️ Nota**: Use Provider conforme padrão da empresa. Outras opções são apenas referência.

---

### 5.2 setState

**When to use**: Simple, local widget state.

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  
  void _increment() {
    setState(() {
      _counter++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_counter'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

**Pros**: Simple, no dependencies  
**Cons**: Doesn't scale, hard to share state, rebuilds entire widget

---

### 5.3 Provider (Recommended for most apps)

**When to use**: App-wide state, MVVM architecture, dependency injection.

```dart
// Model
class Counter extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
}

// Provide at app level
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Counter(),
      child: MyApp(),
    ),
  );
}

// Consume in widgets
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Counter>(
      builder: (context, counter, child) {
        return Column(
          children: [
            Text('Count: ${counter.count}'),
            ElevatedButton(
              onPressed: () => counter.increment(),
              child: Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}
```

**Pros**: Simple, flexible, good for MVVM  
**Cons**: Can lead to boilerplate with many providers

---

### 5.4 Riverpod

**When to use**: Modern alternative to Provider with better safety and testing.

```dart
// Provider definition
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  
  void increment() => state++;
}

// Provide at app level
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Consume in widgets
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

**Pros**: Compile-time safety, no BuildContext needed, easier testing  
**Cons**: Different mental model from Provider

---

### 5.5 BLoC (Business Logic Component)

**When to use**: Large, complex apps with strict separation of concerns.

```dart
// Events
abstract class CounterEvent {}
class IncrementEvent extends CounterEvent {}

// States
class CounterState {
  final int count;
  CounterState(this.count);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
  }
}


// Provide
void main() {
  runApp(
    BlocProvider(
      create: (_) => CounterBloc(),
      child: MyApp(),
    ),
  );
}

// Consume
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Column(
          children: [
            Text('Count: ${state.count}'),
            ElevatedButton(
              onPressed: () {
                context.read<CounterBloc>().add(IncrementEvent());
              },
              child: Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}
```

**Pros**: Strict separation, testable, predictable state flow  
**Cons**: High boilerplate, steep learning curve

---

### 5.6 GetX

**When to use**: Rapid development, simple apps, when you want minimal boilerplate.

```dart
// Controller
class CounterController extends GetxController {
  var count = 0.obs; // Observable
  
  void increment() => count++;
}

// No need to provide - GetX handles it
class CounterWidget extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Text('Count: ${controller.count}')),
        ElevatedButton(
          onPressed: controller.increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

**Pros**: Minimal boilerplate, fast development  
**Cons**: Magic behavior, harder to test, couples code to GetX

---

## 6. Folder Structure

### ⭐ 6.1 MVC Structure (PADRÃO DA EMPRESA)

**Use esta estrutura em todos os projetos:**

```
lib/
├── models/              # MODEL - Entidades e dados
│   ├── user.dart
│   ├── product.dart
│   └── order.dart
│
├── controllers/         # CONTROLLER - Lógica de apresentação
│   ├── auth_controller.dart
│   ├── product_controller.dart
│   └── order_controller.dart
│
├── views/              # VIEW - Interface do usuário
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   └── product_screen.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── product_card.dart
│
├── services/           # Serviços (API, Database, etc)
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── database_service.dart
│
├── repositories/       # Acesso a dados
│   ├── user_repository.dart
│   └── product_repository.dart
│
├── utils/             # Utilitários
│   ├── constants.dart
│   ├── validators.dart
│   └── helpers.dart
│
└── main.dart
```

Ver detalhes completos em: [COMPANY_STANDARDS.md](./COMPANY_STANDARDS.md)

---

### 6.2 Outras Estruturas (REFERÊNCIA APENAS)

**⚠️ As estruturas abaixo são apenas referência técnica. Use MVC da empresa.**

#### Clean Architecture + MVVM (Referência)

```
lib/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
└── main.dart
```

---

## 7. Anti-Patterns

### 7.1 God Object

**Problem**: One class that does everything.

```dart
// ❌ Bad - God class
class AppManager {
  void login() {}
  void logout() {}
  void fetchProducts() {}
  void saveProduct() {}
  void sendEmail() {}
  void logAnalytics() {}
  void handlePayment() {}
  void generateReport() {}
}
```

**Solution**: Split into focused classes.

```dart
// ✅ Good - Focused classes
class AuthService {
  void login() {}
  void logout() {}
}

class ProductRepository {
  void fetchProducts() {}
  void saveProduct() {}
}

class EmailService {
  void sendEmail() {}
}
```

---

### 7.2 Tight Coupling

**Problem**: Classes directly depend on concrete implementations.

```dart
// ❌ Bad - Tightly coupled
class UserViewModel {
  void loadUser() {
    final user = FirebaseFirestore.instance
        .collection('users')
        .doc('123')
        .get();
    // Can't test, can't swap Firebase for another service
  }
}
```

**Solution**: Depend on abstractions.

```dart
// ✅ Good - Loosely coupled
abstract class UserRepository {
  Future<User> getUser(String id);
}

class UserViewModel {
  final UserRepository _repository;
  
  UserViewModel(this._repository);
  
  Future<void> loadUser() async {
    final user = await _repository.getUser('123');
    // Can inject mock repository for testing
  }
}
```

---

### 7.3 Business Logic in UI

**Problem**: Mixing business logic with presentation.

```dart
// ❌ Bad - Logic in widget
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    final response = await http.get(Uri.parse('https://api.example.com/products'));
    final data = jsonDecode(response.body) as List;
    setState(() {
      products = data.map((json) => Product.fromJson(json)).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => Text(products[index].name),
    );
  }
}
```


**Solution**: Extract to ViewModel.

```dart
// ✅ Good - Logic in ViewModel
class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  List<Product> products = [];
  bool isLoading = false;
  
  ProductListViewModel(this._repository);
  
  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();
    
    products = await _repository.getProducts();
    
    isLoading = false;
    notifyListeners();
  }
}

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductListViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: viewModel.products.length,
          itemBuilder: (context, index) {
            return Text(viewModel.products[index].name);
          },
        );
      },
    );
  }
}
```

---

### 7.4 Magic Numbers and Strings

**Problem**: Hard-coded values scattered throughout code.

```dart
// ❌ Bad
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0), // Magic number
      child: Column(
        children: [
          Text('Welcome', style: TextStyle(fontSize: 24)), // Magic number
          SizedBox(height: 20), // Magic number
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home'); // Magic string
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```


**Solution**: Use constants.

```dart
// ✅ Good
class AppConstants {
  static const double defaultPadding = 16.0;
  static const double titleFontSize = 24.0;
  static const double defaultSpacing = 20.0;
}

class Routes {
  static const String home = '/home';
  static const String login = '/login';
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          Text(
            'Welcome',
            style: TextStyle(fontSize: AppConstants.titleFontSize),
          ),
          SizedBox(height: AppConstants.defaultSpacing),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.home);
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

---

### 7.5 Premature Optimization

**Problem**: Optimizing before you know there's a performance issue.

```dart
// ❌ Bad - Over-optimized before measuring
class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000000,
      cacheExtent: 1000, // Premature optimization
      addAutomaticKeepAlives: false, // Premature optimization
      addRepaintBoundaries: false, // Premature optimization
      itemBuilder: (context, index) {
        return RepaintBoundary( // Premature optimization
          child: ProductCard(product: products[index]),
        );
      },
    );
  }
}
```

**Solution**: Start simple, optimize when needed.

```dart
// ✅ Good - Simple first, optimize if needed
class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

// Add optimizations only after profiling shows issues
```

---

*Last Updated: November 2025*  
*Next: [2_SYSTEM_DESIGN.md](./2_SYSTEM_DESIGN.md)*
