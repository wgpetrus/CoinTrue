# 🏛️ Arquitetura do Projeto

Visão geral da arquitetura e padrões utilizados no CoinTrue.

---

## 🎯 Visão Geral

O CoinTrue utiliza uma arquitetura **MVC (Model-View-Controller)** com princípios **SOLID**, garantindo código limpo, testável e manutenível.

---

## 📐 Padrão MVC

### Model (Modelo)
Representa os dados e a lógica de negócio.

```dart
// lib/models/auth/user_model.dart
class User {
  final String id;
  final String email;
  final String? displayName;
  
  const User({
    required this.id,
    required this.email,
    this.displayName,
  });
}
```

### View (Visão)
Interface do usuário (Screens e Widgets).

```dart
// lib/views/screens/auth/login_screen.dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        return Scaffold(/* ... */);
      },
    );
  }
}
```

### Controller (Controlador)
Gerencia a lógica e comunica Model com View.

```dart
// lib/controllers/auth/auth_controller.dart
class AuthController extends ChangeNotifier {
  final AuthService _authService;
  
  Future<void> login(String email, String password) async {
    // Lógica de login
    notifyListeners();
  }
}
```

---

## 🔄 Fluxo de Dados

```
┌─────────────────────────────────────────────────┐
│                    VIEW                         │
│  (Screens & Widgets)                           │
│  - Exibe UI                                    │
│  - Captura eventos do usuário                 │
└──────────────┬──────────────────────────────────┘
               │ User Action
               ↓
┌─────────────────────────────────────────────────┐
│                 CONTROLLER                      │
│  (Business Logic)                              │
│  - Processa ações                              │
│  - Valida dados                                │
│  - Gerencia estado                             │
└──────────────┬──────────────────────────────────┘
               │ Data Request
               ↓
┌─────────────────────────────────────────────────┐
│                 REPOSITORY                      │
│  (Data Abstraction)                            │
│  - Abstrai fonte de dados                      │
│  - Cache local                                 │
└──────────────┬──────────────────────────────────┘
               │ API Call
               ↓
┌─────────────────────────────────────────────────┐
│                  SERVICE                        │
│  (External Integration)                        │
│  - Firebase                                    │
│  - APIs externas                               │
│  - Local Storage                               │
└──────────────┬──────────────────────────────────┘
               │ Raw Data
               ↓
┌─────────────────────────────────────────────────┐
│                   MODEL                         │
│  (Data Structure)                              │
│  - Estrutura de dados                          │
│  - Serialização                                │
│  - Validação                                   │
└─────────────────────────────────────────────────┘
```

---

## 🎨 Gerenciamento de Estado

### Provider Pattern

Utilizamos **Provider** para gerenciamento de estado reativo.

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController(...)),
    ChangeNotifierProvider(create: (_) => CryptoController(...)),
    ChangeNotifierProvider(create: (_) => FavoritesController(...)),
  ],
  child: MyApp(),
)
```

### Consumindo Estado

```dart
// Opção 1: Consumer
Consumer<AuthController>(
  builder: (context, auth, child) {
    return Text(auth.user?.email ?? 'Not logged in');
  },
)

// Opção 2: Provider.of
final auth = Provider.of<AuthController>(context);

// Opção 3: context.watch (mais moderno)
final auth = context.watch<AuthController>();
```

---

## 🗄️ Repository Pattern

Abstrai a fonte de dados, facilitando testes e manutenção.

```dart
// Interface
abstract class UserRepository {
  Future<User?> getUser(String id);
  Future<void> saveUser(User user);
}

// Implementação Firebase
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  
  @override
  Future<User?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    return User.fromJson(doc.data()!);
  }
}
```

---

## 🔌 Service Layer

Serviços encapsulam integrações externas.

### Tipos de Services

1. **Auth Services** - Firebase Auth, Biometria
2. **API Services** - CoinGecko, APIs externas
3. **Storage Services** - SharedPreferences, SecureStorage
4. **Notification Services** - FCM, Local Notifications

```dart
// lib/services/auth/firebase_auth_service.dart
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  
  @override
  Future<User> signInWithGoogle() async {
    final credential = await GoogleSignIn().signIn();
    final authResult = await _auth.signInWithCredential(credential);
    return User.fromFirebase(authResult.user!);
  }
}
```

---

## 🧩 Princípios SOLID

### Single Responsibility
Cada classe tem uma única responsabilidade.

```dart
// ✅ Correto
class UserRepository { /* apenas acesso a dados */ }
class AuthController { /* apenas lógica de auth */ }

// ❌ Incorreto
class UserManager { /* auth + dados + validação */ }
```

### Open/Closed
Aberto para extensão, fechado para modificação.

```dart
// Interface
abstract class AuthService {
  Future<User> signIn();
}

// Implementações
class GoogleAuthService implements AuthService { }
class AppleAuthService implements AuthService { }
```

### Liskov Substitution
Subclasses podem substituir classes base.

```dart
AuthService auth = GoogleAuthService(); // ✅
auth = AppleAuthService(); // ✅ Funciona igual
```

### Interface Segregation
Interfaces específicas ao invés de genéricas.

```dart
// ✅ Correto
abstract class Readable { Future<Data> read(); }
abstract class Writable { Future<void> write(Data data); }

// ❌ Incorreto
abstract class DataAccess {
  Future<Data> read();
  Future<void> write(Data data);
  Future<void> delete(String id);
  // Muitos métodos...
}
```

### Dependency Inversion
Dependa de abstrações, não de implementações.

```dart
// ✅ Correto
class AuthController {
  final AuthService _authService; // Interface
  AuthController(this._authService);
}

// ❌ Incorreto
class AuthController {
  final FirebaseAuthService _authService; // Implementação concreta
}
```

---

## 🔐 Segurança

### Autenticação
- Firebase Authentication
- Tokens JWT
- Refresh tokens automáticos

### Armazenamento Seguro
```dart
// Dados sensíveis
FlutterSecureStorage().write(key: 'token', value: token);

// Dados não sensíveis
SharedPreferences.setString('theme', 'light');
```

### Validação
```dart
// Input validation
if (!EmailValidator.validate(email)) {
  throw InvalidEmailException();
}

// Sanitização
final sanitized = HtmlEscape().convert(userInput);
```

---

## 🚀 Performance

### Lazy Loading
```dart
// Carregar dados sob demanda
late final CryptoController _cryptoController;

@override
void initState() {
  super.initState();
  _cryptoController = context.read<CryptoController>();
}
```

### Cache
```dart
// Cache de imagens
CachedNetworkImage(
  imageUrl: crypto.imageUrl,
  cacheKey: crypto.id,
)

// Cache de dados
class CryptoRepository {
  final Map<String, Crypto> _cache = {};
  
  Future<Crypto> getCrypto(String id) async {
    if (_cache.containsKey(id)) return _cache[id]!;
    final crypto = await _api.getCrypto(id);
    _cache[id] = crypto;
    return crypto;
  }
}
```

### Debouncing
```dart
// Busca com debounce
Timer? _debounce;

void onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

---

## 🧪 Testabilidade

### Dependency Injection
```dart
// Facilita mocking em testes
class AuthController {
  final AuthService authService;
  final UserRepository userRepository;
  
  AuthController({
    required this.authService,
    required this.userRepository,
  });
}

// No teste
final mockAuth = MockAuthService();
final mockRepo = MockUserRepository();
final controller = AuthController(
  authService: mockAuth,
  userRepository: mockRepo,
);
```

### Interfaces
```dart
// Permite criar mocks facilmente
abstract class AuthService {
  Future<User> signIn(String email, String password);
}

// Mock para testes
class MockAuthService implements AuthService {
  @override
  Future<User> signIn(String email, String password) async {
    return User(id: '123', email: email);
  }
}
```

---

## 📊 Diagrama de Componentes

```
┌─────────────────────────────────────────────────┐
│                   PRESENTATION                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Screens  │  │ Widgets  │  │ Dialogs  │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────┐
│                  CONTROLLERS                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │   Auth   │  │  Crypto  │  │Favorites │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────┐
│                 REPOSITORIES                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │   User   │  │  Crypto  │  │ Wallet   │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────┐
│                   SERVICES                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Firebase │  │CoinGecko │  │   FCM    │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└─────────────────────────────────────────────────┘
```

---

## ✅ Benefícios da Arquitetura

1. **Manutenibilidade** - Código organizado e fácil de manter
2. **Testabilidade** - Fácil criar testes unitários e de integração
3. **Escalabilidade** - Fácil adicionar novas features
4. **Reusabilidade** - Componentes reutilizáveis
5. **Separação de Responsabilidades** - Cada camada tem seu papel
6. **Flexibilidade** - Fácil trocar implementações

---

**Arquitetura sólida = Código de qualidade**
