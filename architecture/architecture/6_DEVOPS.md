# 6. DevOps

## Table of Contents

1. [Git Workflow](#1-git-workflow)
2. [CI/CD Pipelines](#2-cicd-pipelines)
3. [Automated Testing](#3-automated-testing)
4. [Monitoring](#4-monitoring)
5. [Release Management](#5-release-management)

---

## 1. Git Workflow

### 1.1 Branch Strategy (Git Flow)

```
main (production)
  │
  ├── develop (integration)
  │     │
  │     ├── feature/user-authentication
  │     ├── feature/product-catalog
  │     └── feature/payment-integration
  │
  ├── release/v1.2.0 (release preparation)
  │
  └── hotfix/critical-bug-fix (emergency fixes)
```

**Branch Types**:

| Branch | Purpose | Naming | Lifetime |
|--------|---------|--------|----------|
| **main** | Production code | `main` | Permanent |
| **develop** | Integration branch | `develop` | Permanent |
| **feature** | New features | `feature/feature-name` | Temporary |
| **release** | Release preparation | `release/v1.2.0` | Temporary |
| **hotfix** | Emergency fixes | `hotfix/bug-description` | Temporary |

<!-- AI_NOTE: Keep main stable. All development happens in feature branches, merged to develop, then to main via release branches. -->

---

### 1.2 Commit Message Convention

**Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:

```
feat(auth): add Google sign-in

Implement Google OAuth authentication flow using Firebase Auth.
Includes error handling and user profile creation.

Closes #123
```

```
fix(payment): resolve crash on checkout

Fixed null pointer exception when user has no saved payment methods.

Fixes #456
```

---

### 1.3 Pull Request Workflow

```
1. Create feature branch
   git checkout -b feature/user-authentication

2. Make changes and commit
   git add .
   git commit -m "feat(auth): implement login functionality"

3. Push to remote
   git push origin feature/user-authentication

4. Create Pull Request on GitHub/GitLab

5. Code Review
   - Reviewers provide feedback
   - Author makes changes
   - Push updates to same branch

6. Approval and Merge
   - Squash and merge (clean history)
   - Delete feature branch

7. Deploy
   - CI/CD automatically deploys to staging
   - Manual promotion to production
```

---

## 2. CI/CD Pipelines

### 2.1 CI/CD Concepts

**Continuous Integration (CI)**:
- Automatically build and test code on every commit
- Catch bugs early
- Ensure code quality

**Continuous Deployment (CD)**:
- Automatically deploy to staging/production
- Faster releases
- Reduced manual errors

```
┌──────────────────────────────────────────────────────┐
│                  CI/CD PIPELINE                      │
└──────────────────────────────────────────────────────┘

Code Push
    │
    ▼
┌────────────┐
│   Build    │  Compile code, install dependencies
└─────┬──────┘
      │
      ▼
┌────────────┐
│   Test     │  Run unit, widget, integration tests
└─────┬──────┘
      │
      ▼
┌────────────┐
│  Analyze   │  Lint, format check, static analysis
└─────┬──────┘
      │
      ▼
┌────────────┐
│   Deploy   │  Deploy to staging/production
│  (Staging) │
└─────┬──────┘
      │
      ▼
┌────────────┐
│   Deploy   │  Manual approval, deploy to prod
│   (Prod)   │
└────────────┘
```

---

### 2.2 Codemagic Configuration

```yaml
# codemagic.yaml
workflows:
  flutter-workflow:
    name: Flutter Build
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    
    scripts:
      - name: Get dependencies
        script: flutter pub get
      
      - name: Analyze code
        script: flutter analyze
      
      - name: Run tests
        script: flutter test
      
      - name: Build Android
        script: |
          flutter build apk --release
          flutter build appbundle --release
      
      - name: Build iOS
        script: |
          flutter build ios --release --no-codesign
    
    artifacts:
      - build/**/outputs/**/*.apk
      - build/**/outputs/**/*.aab
      - build/ios/ipa/*.ipa
    
    publishing:
      email:
        recipients:
          - dev@example.com
      
      google_play:
        credentials: $GOOGLE_PLAY_CREDENTIALS
        track: internal
      
      app_store_connect:
        api_key: $APP_STORE_CONNECT_KEY
        submit_to_testflight: true
```

---

## 3. Automated Testing

### 3.1 Test Automation Strategy

```yaml
# .github/workflows/test.yml
name: Automated Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/unit/
  
  widget-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/widget/
  
  integration-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter drive --target=test_driver/app.dart
```

---

## 4. Monitoring

### 4.1 Firebase Crashlytics

```dart
class CrashlyticsService {
  static Future<void> initialize() async {
    // Enable Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Catch Flutter errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  static Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }
  
  static Future<void> setUserIdentifier(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
  
  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }
}

// Usage
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CrashlyticsService.initialize();
  
  runApp(MyApp());
}
```

---

### 4.2 Analytics

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
  
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
  
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}

// Usage
class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  
  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('product_screen');
  }
  
  void _onProductPurchased(Product product) {
    _analytics.logEvent('purchase', {
      'product_id': product.id,
      'product_name': product.name,
      'price': product.price,
    });
  }
}
```

---

## 5. Release Management

### 5.1 Versioning Strategy

**Semantic Versioning**: MAJOR.MINOR.PATCH

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

```yaml
# pubspec.yaml
version: 1.2.3+10
#         │ │ │  │
#         │ │ │  └─ Build number (increments with each build)
#         │ │ └──── Patch version
#         │ └────── Minor version
#         └──────── Major version
```

---

### 5.2 Release Checklist

```markdown
## Release Checklist

### Pre-Release
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Changelog updated
- [ ] Version number bumped
- [ ] Release notes written
- [ ] Staging deployment successful

### Release
- [ ] Create release branch
- [ ] Build production artifacts
- [ ] Upload to app stores
- [ ] Tag release in Git
- [ ] Deploy backend changes (if any)

### Post-Release
- [ ] Monitor crash reports
- [ ] Check analytics
- [ ] Verify key features working
- [ ] Respond to user feedback
- [ ] Update documentation
```

---

### 5.3 Rollback Strategy

```bash
# If release has critical issues

# 1. Revert to previous version in app stores
# (Manual process in App Store Connect / Play Console)

# 2. Revert code changes
git revert <commit-hash>
git push origin main

# 3. Deploy previous version
git checkout v1.2.2
./deploy.sh production

# 4. Communicate with users
# - Send push notification
# - Update status page
# - Post on social media
```

---

*Last Updated: November 2025*  
*Next: [7_SECURITY.md](./7_SECURITY.md)*
