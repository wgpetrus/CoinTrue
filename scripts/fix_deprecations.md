# Script de Correção de Deprecations

## Correções Automáticas Possíveis

### 1. withOpacity → withValues

**Buscar e substituir em todo o projeto:**

```regex
Buscar: \.withOpacity\(([0-9.]+)\)
Substituir: .withValues(alpha: $1)
```

**Exemplo:**
```dart
// Antes
colors.primary.withOpacity(0.5)

// Depois
colors.primary.withValues(alpha: 0.5)
```

---

### 2. Remover Imports Não Utilizados

**Executar:**
```bash
dart fix --apply
```

Ou manualmente remover:

**lib/main.dart:**
```dart
// Remover estas linhas:
import 'services/crypto/crypto_services.dart';
import 'repositories/crypto/crypto_repositories.dart';
import 'utils/error_handler.dart';
```

**lib/services/common/initialization_service.dart:**
```dart
// Remover estas linhas:
import 'dart:io';
import '../../utils/error_handler.dart';
```

**lib/views/screens/crypto/crypto_detail_screen.dart:**
```dart
// Remover esta linha:
import 'package:flutter_animate/flutter_animate.dart';
```

**lib/views/screens/crypto/home_screen.dart:**
```dart
// Remover esta linha:
import '../../../utils/responsive_layout.dart';
```

---

### 3. WillPopScope → PopScope

**lib/views/screens/auth/biometric_lock_screen.dart:**

```dart
// Antes
WillPopScope(
  onWillPop: () async => false,
  child: Scaffold(...),
)

// Depois
PopScope(
  canPop: false,
  child: Scaffold(...),
)
```

---

### 4. Prefer isEmpty

**lib/controllers/crypto/crypto_controller.dart (linha 89):**

```dart
// Antes
if (_cryptos.length > 0) {

// Depois
if (_cryptos.isNotEmpty) {
```

---

### 5. Avoid Print

**lib/repositories/crypto/wallet_repository_impl.dart:**

```dart
// Antes
print('Wallet loaded: ...');

// Depois
debugPrint('Wallet loaded: ...');
```

---

### 6. Use BuildContext Synchronously

**Padrão a seguir:**

```dart
// Antes
Future<void> myMethod() async {
  await someAsyncOperation();
  Navigator.pop(context); // ❌ Perigoso
}

// Depois
Future<void> myMethod() async {
  await someAsyncOperation();
  if (!mounted) return; // ✅ Seguro
  Navigator.pop(context);
}
```

**Arquivos a corrigir:**
- `lib/views/screens/auth/biometric_lock_screen.dart` (linhas 365, 367)
- `lib/views/screens/auth/email_verification_screen.dart` (linha 381)
- `lib/views/screens/crypto/convert_crypto_screen.dart` (linhas 1011, 1017)

---

### 7. Prefer Initializing Formals

**lib/models/auth/auth_state_model.dart:**

```dart
// Antes
class AuthState {
  final bool isAuthenticated;
  
  AuthState({required bool isAuthenticated}) 
    : isAuthenticated = isAuthenticated;
}

// Depois
class AuthState {
  final bool isAuthenticated;
  
  AuthState({required this.isAuthenticated});
}
```

---

## Executar Todas as Correções

```bash
# 1. Análise
flutter analyze

# 2. Correções automáticas
dart fix --apply

# 3. Formatar código
dart format .

# 4. Verificar novamente
flutter analyze

# 5. Rodar testes
flutter test
```

---

## Checklist de Correções

- [ ] withOpacity → withValues (40+ ocorrências)
- [ ] Remover imports não utilizados (5 arquivos)
- [ ] WillPopScope → PopScope (1 arquivo)
- [ ] length > 0 → isNotEmpty (1 ocorrência)
- [ ] print → debugPrint (2 ocorrências)
- [ ] Adicionar mounted checks (4 arquivos)
- [ ] Initializing formals (2 arquivos)
- [ ] Remover código morto (2 itens)

---

## Tempo Estimado

- Correções automáticas: 30 minutos
- Correções manuais: 2 horas
- Testes: 30 minutos
- **Total: ~3 horas**

---

## Após Correções

1. Executar `flutter analyze` - deve mostrar 0 erros
2. Executar `flutter test` - todos os testes devem passar
3. Testar app manualmente em Android/iOS
4. Commit: `fix: corrigir deprecations e warnings do Flutter`
