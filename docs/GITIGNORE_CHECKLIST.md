# Checklist de Segurança - .gitignore

## ✅ Arquivos Removidos do Git

Os seguintes arquivos foram **removidos do histórico** e agora estão no `.gitignore`:

1. ✅ `firebase.json` - Contém IDs de projeto e configurações
2. ✅ `storage.rules` - Regras de segurança (podem revelar estrutura)
3. ✅ `google-services.json` - Nunca foi commitado (bom!)

## 🔒 Arquivos Sensíveis Protegidos

### Firebase
- ✅ `**/google-services.json` (Android OAuth)
- ✅ `**/GoogleService-Info.plist` (iOS OAuth)
- ✅ `**/firebase-adminsdk-*.json` (Service Account Keys)
- ✅ `firebase.json` (IDs de projeto)
- ✅ `storage.rules` (regras de segurança)
- ✅ `.firebase/` (cache do Firebase CLI)
- ✅ `.firebaserc` (configurações locais)

### Node.js / Functions
- ✅ `**/node_modules/`
- ✅ `**/package-lock.json`
- ✅ `functions/lib/` (JS compilado)
- ✅ `**/.runtimeconfig.json` (runtime secrets)

### Build Artifacts
- ✅ `*.apk`, `*.aab`, `*.ipa`
- ✅ `/build/`
- ✅ `.dart_tool/`
- ✅ Android: `.gradle/`, `.kotlin/`, `local.properties`
- ✅ iOS: `Pods/`, `xcuserdata/`

### Credenciais
- ✅ `.env`, `.env.local`, `.env.*.local`
- ✅ `*.jks`, `*.keystore` (Android signing keys)
- ✅ `key.properties` (Android key config)

### IDE
- ✅ `.idea/`
- ✅ `.vscode/settings.json`
- ✅ `.kiro/cache/`, `.kiro/logs/`

## ⚠️ Arquivos que DEVEM estar no Git

### Firebase (Públicos)
- ✅ `lib/core/config/firebase_options.dart` - Seguro, IDs públicos

### Código
- ✅ Todo código fonte em `lib/`, `test/`
- ✅ `pubspec.yaml`, `pubspec.lock`
- ✅ `analysis_options.yaml`

### Documentação
- ✅ `README.md`, `CHANGELOG.md`
- ✅ `docs/*.md`


**Não deve aparecer:**
- ❌ `google-services.json`
- ❌ `GoogleService-Info.plist`
- ❌ `firebase.json`
- ❌ `storage.rules`
- ❌ `node_modules/`
- ❌ `.env`

**Deve aparecer apenas:**
- ✅ Código fonte (`.dart`)
- ✅ `firebase_options.dart`
- ✅ Documentação (`.md`)
- ✅ Configurações públicas

## 🔐 Boas Práticas

1. **Nunca commitar:**
   - Senhas, tokens, API keys privadas
   - Service account keys
   - Certificados de assinatura
   - Arquivos de configuração com secrets

2. **Sempre usar:**
   - Variáveis de ambiente (`.env`)
   - Secrets do CI/CD
   - Firebase Remote Config para configs dinâmicas

## 📚 Referências

- [Firebase Security Best Practices](https://firebase.google.com/support/guides/security-checklist)
- [Git Ignore Best Practices](https://github.com/github/gitignore)
- [Flutter Security Guidelines](https://docs.flutter.dev/security)
