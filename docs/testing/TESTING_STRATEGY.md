# 🧪 Estratégia de Testes

## Visão Geral

O projeto possui **181 testes automatizados** (100% passando) que garantem a qualidade e estabilidade do código.

---

## Pirâmide de Testes

```
        ┌─────────────┐
        │   E2E (0)   │  ← Futuro
        └─────────────┘
       ┌───────────────┐
       │ Integration   │  ← 50+ testes
       │   (50+)       │
       └───────────────┘
      ┌─────────────────┐
      │   Unit Tests    │  ← 120+ testes
      │     (120+)      │
      └─────────────────┘
     ┌───────────────────┐
     │  Widget Tests     │  ← 11+ testes
     │     (11+)         │
     └───────────────────┘
```

---

## Tipos de Testes

### 1. Testes Unitários (120+)

**Objetivo:** Testar unidades isoladas de código

**Cobertura:**
- ✅ Controllers (60+)
- ✅ Services (40+)
- ✅ Utils (20+)

**Exemplo:**
```dart
test('CryptoController deve carregar criptos', () async {
  // Arrange
  final mockRepo = MockCryptoRepository();
  final controller = CryptoController(mockRepo);
  
  when(mockRepo.getCryptos()).thenAnswer(
    (_) async => [Crypto(id: 'btc', name: 'Bitcoin')],
  );
  
  // Act
  await controller.loadCryptos();
  
  // Assert
  expect(controller.cryptos.length, 1);
  expect(controller.cryptos[0].name, 'Bitcoin');
});
```

### 2. Testes de Integração (50+)

**Objetivo:** Testar interação entre componentes

**Cobertura:**
- ✅ Fluxos completos
- ✅ Controller + Service + Repository
- ✅ Firebase mockado

**Exemplo:**
```dart
test('Fluxo completo de login', () async {
  // Arrange
  final authService = MockFirebaseAuthService();
  final authController = AuthController(authService);
  
  // Act
  await authController.loginWithGoogle();
  
  // Assert
  expect(authController.isAuthenticated, true);
  expect(authController.currentUser, isNotNull);
});
```

### 3. Property-Based Tests (30+)

**Objetivo:** Testar propriedades e casos extremos

**Cobertura:**
- ✅ Rate Limiter
- ✅ Validators
- ✅ Error Handler

**Exemplo:**
```dart
test('Rate limiter deve bloquear após 5 tentativas', () async {
  final limiter = RateLimiter();
  
  // Simula 5 falhas
  for (int i = 0; i < 5; i++) {
    await limiter.recordFailure('test@email.com');
  }
  
  // Deve estar bloqueado
  expect(limiter.isBlocked('test@email.com'), true);
});
```

### 4. Widget Tests (11+)

**Objetivo:** Testar componentes UI

**Cobertura:**
- ✅ Widgets customizados
- ✅ Interações do usuário
- ✅ Estados visuais

**Exemplo:**
```dart
testWidgets('LoginButton deve exibir loading', (tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(
      home: LoginButton(isLoading: true),
    ),
  );
  
  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## Estrutura de Testes

```
test/
├── controllers/
│   ├── auth_controller_test.dart
│   ├── crypto_controller_test.dart
│   └── wallet_controller_test.dart
├── services/
│   ├── firebase_auth_service_test.dart
│   └── coingecko_api_service_test.dart
├── utils/
│   ├── validators_test.dart
│   ├── error_handler_test.dart
│   └── rate_limiter_test.dart
└── widgets/
    ├── crypto_list_item_test.dart
    └── loading_overlay_test.dart
```

---

## Ferramentas

### Principais

- **flutter_test:** Framework de testes
- **mockito:** Criação de mocks
- **fake_cloud_firestore:** Mock do Firestore
- **firebase_auth_mocks:** Mock do Firebase Auth

### Auxiliares

- **test:** Testes Dart puro
- **integration_test:** Testes E2E (futuro)

---

## Executar Testes

### Todos os testes
```bash
flutter test
```

### Com cobertura
```bash
flutter test --coverage
```

### Testes específicos
```bash
# Por pasta
flutter test test/controllers/

# Por arquivo
flutter test test/controllers/auth_controller_test.dart

# Por nome
flutter test --name "login"
```

### Watch mode
```bash
flutter test --watch
```

---

## Mocks

### Criação de Mocks

```dart
// 1. Importar mockito
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// 2. Gerar mock
@GenerateMocks([FirebaseAuthService])
void main() {
  // Mocks gerados automaticamente
}

// 3. Usar mock
final mockService = MockFirebaseAuthService();

when(mockService.signIn()).thenAnswer(
  (_) async => User(id: '123'),
);
```

### Mocks Disponíveis

- `MockFirebaseAuthService`
- `MockCryptoRepository`
- `MockWalletRepository`
- `MockNotificationService`

---

## Cobertura de Código

### Atual

| Componente | Cobertura |
|------------|-----------|
| Controllers | ~90% |
| Services | ~85% |
| Utils | ~95% |
| Widgets | ~70% |
| **Média** | **~85%** |

### Gerar Relatório

```bash
# Gerar cobertura
flutter test --coverage

# Visualizar (requer lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Boas Práticas

### 1. AAA Pattern

```dart
test('description', () {
  // Arrange (Preparar)
  final controller = AuthController();
  
  // Act (Agir)
  await controller.login();
  
  // Assert (Verificar)
  expect(controller.isAuthenticated, true);
});
```

### 2. Nomes Descritivos

```dart
// ✅ BOM
test('AuthController deve autenticar usuário com credenciais válidas', () {});

// ❌ RUIM
test('test login', () {});
```

### 3. Testes Independentes

```dart
// ✅ BOM - Cada teste cria seu próprio controller
test('test 1', () {
  final controller = AuthController();
  // ...
});

test('test 2', () {
  final controller = AuthController();
  // ...
});

// ❌ RUIM - Compartilha estado
final controller = AuthController();

test('test 1', () {
  controller.login();
});

test('test 2', () {
  controller.logout(); // Depende do test 1
});
```

### 4. Mocks Específicos

```dart
// ✅ BOM - Mock específico para o teste
when(mockService.getUser()).thenAnswer(
  (_) async => User(id: '123', name: 'Test'),
);

// ❌ RUIM - Mock genérico
when(mockService.getUser()).thenAnswer((_) async => null);
```

---

## CI/CD

### GitHub Actions

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
```

---

## Métricas

### Atuais

- **Total de Testes:** 181
- **Testes Passando:** 181 (100%)
- **Testes Falhando:** 0
- **Tempo de Execução:** ~15 segundos
- **Cobertura:** ~85%

### Metas

- **Total de Testes:** 200+
- **Cobertura:** 90%+
- **Tempo de Execução:** < 20 segundos

---

## Troubleshooting

### Testes Lentos

**Solução:**
```dart
// Use fake_async para testes com delays
testWidgets('test', (tester) async {
  await tester.runAsync(() async {
    // Código assíncrono
  });
});
```

### Mocks Não Funcionam

**Solução:**
```bash
# Regenerar mocks
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testes Flaky

**Solução:**
```dart
// Adicione pump/pumpAndSettle
await tester.pump();
await tester.pumpAndSettle();
```

---

## Documentos Relacionados

- [Como Escrever Testes](./WRITING_TESTS.md)
- [Cobertura de Testes](./COVERAGE.md)
- [Guia de Desenvolvimento](../development/DEVELOPMENT_GUIDE.md)

---

**Última atualização:** 06/12/2025
