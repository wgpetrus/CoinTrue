# Widgets Reutilizáveis

Este diretório contém widgets customizados e reutilizáveis organizados por categoria.

## Estrutura

```
widgets/
├── common/          # Widgets genéricos reutilizáveis
│   ├── social_login_button.dart
│   ├── loading_overlay.dart
│   └── error_message.dart
│
├── auth/            # Widgets específicos de autenticação
│   └── biometric_prompt.dart
│
├── crypto/          # Widgets específicos de crypto
│   ├── crypto_card.dart
│   ├── crypto_list_item.dart
│   └── ...
│
└── widgets.dart     # Barrel file (importar daqui)
```

## Widgets Disponíveis

### 1. SocialLoginButton

Botão customizado para login social (Google/Apple) com estados de loading e disabled.

**Uso:**
```dart
import 'package:login/views/widgets/widgets.dart';

SocialLoginButton(
  provider: SocialProvider.google,
  onPressed: () => controller.signInWithGoogle(),
  isLoading: controller.isLoading,
)
```

**Parâmetros:**
- `provider`: `SocialProvider.google` ou `SocialProvider.apple`
- `onPressed`: Callback executado ao pressionar o botão
- `isLoading`: Indica se está em estado de loading (opcional, padrão: false)

### 2. LoadingOverlay

Overlay semi-transparente com spinner que bloqueia interações durante operações.

**Uso:**
```dart
import 'package:login/views/widgets/widgets.dart';

LoadingOverlay(
  isLoading: controller.isLoading,
  message: 'Autenticando...',
  child: YourContentWidget(),
)
```

**Parâmetros:**
- `isLoading`: Controla a visibilidade do overlay
- `child`: Widget filho que será coberto pelo overlay
- `message`: Mensagem opcional exibida no loading (opcional)

### 3. BiometricPrompt

Card com prompt para autenticação biométrica.

**Uso:**
```dart
import 'package:login/views/widgets/widgets.dart';

BiometricPrompt(
  onAuthenticate: () => controller.signInWithBiometric(),
  onSkip: () => Navigator.pop(context),
  isAuthenticating: controller.isLoading,
)
```

**Parâmetros:**
- `onAuthenticate`: Callback para autenticar com biometria
- `onSkip`: Callback para pular a biometria
- `isAuthenticating`: Indica se está autenticando (opcional, padrão: false)

### 4. ErrorMessage

Widget para exibir mensagens de erro com opção de retry.

**Uso:**
```dart
import 'package:login/views/widgets/widgets.dart';

ErrorMessage(
  message: controller.error ?? '',
  onRetry: () => controller.signInWithGoogle(),
  showRetry: true,
)
```

**Parâmetros:**
- `message`: Mensagem de erro a ser exibida
- `onRetry`: Callback para tentar novamente (opcional)
- `showRetry`: Controla a visibilidade do botão retry (opcional, padrão: true)

## Design System

Todos os widgets seguem o design system do aplicativo CoinTrue:

- **Cores:**
  - Azul Primário (#2563EB): Botões primários e destaques
  - Azul Escuro (#1E40AF): Ícones e textos em fundo branco
  - Roxo Secundário (#7C3AED): Elementos secundários e gradientes
  - Cinza escuro (#545454): Textos e elementos secundários
  - Branco (#FFFFFF): Backgrounds
  - Vermelho (#F44336): Estados de erro
  - Verde (#4CAF50): Estados de sucesso

- **Estilo:** Material Design clean e moderno
- **Responsividade:** Adaptável a diferentes tamanhos de tela

## Requisitos Atendidos

- **1.1, 1.2**: Login social com Google e Apple
- **2.4, 2.5**: Autenticação biométrica
- **5.1-5.5**: Tratamento de erros
- **7.1-7.3**: Estados de carregamento e feedback visual
