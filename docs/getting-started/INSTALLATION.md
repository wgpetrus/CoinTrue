# 📦 Instalação e Configuração

## Pré-requisitos

### Obrigatórios
- **Flutter SDK** 3.32.3 ou superior
- **Dart** 3.0 ou superior
- **Git** para controle de versão

### Para Desenvolvimento Mobile
- **Android Studio** (para Android)
- **Xcode** (para iOS - apenas macOS)
- **Android SDK** 21 ou superior
- **iOS** 12.0 ou superior

### Para Firebase
- **Firebase CLI** instalado
- **Node.js** 14 ou superior
- Conta no Firebase Console

---

## Instalação do Flutter

### Windows
```bash
# Baixe o Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# Adicione ao PATH
# C:\src\flutter\bin

# Verifique a instalação
flutter doctor
```

### macOS
```bash
# Usando Homebrew
brew install flutter

# Ou baixe manualmente
# https://docs.flutter.dev/get-started/install/macos

# Verifique a instalação
flutter doctor
```

### Linux
```bash
# Baixe e extraia
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.3-stable.tar.xz
tar xf flutter_linux_3.32.3-stable.tar.xz

# Adicione ao PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verifique a instalação
flutter doctor
```

---

## Clone do Projeto

```bash
# Clone o repositório
git clone [URL_DO_REPOSITORIO]

# Entre na pasta
cd cointrue

# Verifique a branch
git branch
```

---

## Instalação de Dependências

```bash
# Instale as dependências do Flutter
flutter pub get

# Verifique se tudo está OK
flutter doctor -v
```

---

## Configuração do Ambiente

### 1. Crie o arquivo de configuração local

```bash
# Copie o arquivo de exemplo
cp .env.example .env
```

### 2. Configure as variáveis de ambiente

Edite o arquivo `.env`:

```env
# Firebase
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id

# CoinGecko API
COINGECKO_API_KEY=your_api_key_here

# Ambiente
ENVIRONMENT=development
```

---

## Configuração do Firebase

Siga o guia detalhado: [Firebase Setup](./FIREBASE_SETUP.md)

---

## Verificação da Instalação

```bash
# Execute os testes
flutter test

# Deve mostrar: 181 tests passed
```

---

## Executar o App

### Android
```bash
# Liste os dispositivos
flutter devices

# Execute no emulador/dispositivo
flutter run
```

### iOS
```bash
# Abra o simulador
open -a Simulator

# Execute
flutter run
```

### Web
```bash
flutter run -d chrome
```

---

## Problemas Comuns

### Flutter Doctor Issues

**Problema:** Android licenses not accepted
```bash
flutter doctor --android-licenses
```

**Problema:** Xcode not configured
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Dependências

**Problema:** Pub get failed
```bash
flutter clean
flutter pub get
```

**Problema:** CocoaPods (iOS)
```bash
cd ios
pod install
cd ..
```

---

## Próximos Passos

1. [Configurar Firebase](./FIREBASE_SETUP.md)
2. [Primeiro Uso](./FIRST_RUN.md)
3. [Guia de Desenvolvimento](../development/DEVELOPMENT_GUIDE.md)

---

**Última atualização:** 06/12/2025
