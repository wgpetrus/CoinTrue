# 7. Security

## Table of Contents

1. [Authentication vs Authorization](#1-authentication-vs-authorization)
2. [Secure Coding Principles](#2-secure-coding-principles)
3. [API Security](#3-api-security)
4. [Data Protection](#4-data-protection)
5. [OWASP Top 10](#5-owasp-top-10)
6. [Common Vulnerabilities](#6-common-vulnerabilities)

---

## 1. Authentication vs Authorization

### 1.1 Definitions

**Authentication**: Verifying who you are (identity)  
**Authorization**: Verifying what you can do (permissions)

```
┌─────────────────────────────────────────────────────────┐
│                  AUTH FLOW                              │
└─────────────────────────────────────────────────────────┘

User enters credentials
         │
         ▼
┌────────────────────┐
│  AUTHENTICATION    │  "Who are you?"
│  - Verify identity │
│  - Check password  │
│  - Issue token     │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  AUTHORIZATION     │  "What can you do?"
│  - Check roles     │
│  - Verify perms    │
│  - Allow/Deny      │
└────────────────────┘
```

<!-- AI_NOTE: Always authenticate first, then authorize. Never trust client-side authorization checks - always verify on the server. -->

---

### 1.2 JWT (JSON Web Tokens)

**Structure**:
```
header.payload.signature
```

**Example Implementation**:

```dart
class AuthService {
  final String _secretKey = 'your-secret-key'; // Store securely!
  
  // Generate JWT token
  String generateToken(User user) {
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'role': user.role,
      'exp': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
    });
    
    return jwt.sign(SecretKey(_secretKey));
  }
  
  // Verify JWT token
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload;
    } catch (e) {
      return null; // Invalid token
    }
  }
}
```

**Flutter API Client with JWT**:

```dart
class ApiClient {
  final Dio _dio = Dio();
  String? _token;
  
  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  Future<Response> get(String path) async {
    return await _dio.get(path);
  }
}
```

---

## 2. Secure Coding Principles

### 2.1 Input Validation

**Always validate user input**:

```dart
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  // Sanitize input (prevent XSS)
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
}
```

---

### 2.2 Secure Data Storage

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  // Store sensitive data
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  // Retrieve sensitive data
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // Delete sensitive data
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

// ❌ Bad - Storing sensitive data in SharedPreferences
class InsecureStorage {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token); // NOT ENCRYPTED!
  }
}
```

---

## 3. API Security

### 3.1 API Key Management

```dart
// ❌ Bad - Hardcoded API key
class ApiClient {
  final String apiKey = 'sk_live_abc123xyz'; // NEVER DO THIS!
}

// ✅ Good - Environment variables
class ApiClient {
  final String apiKey = const String.fromEnvironment('API_KEY');
  
  ApiClient() {
    if (apiKey.isEmpty) {
      throw Exception('API_KEY not configured');
    }
  }
}

// Run with:
// flutter run --dart-define=API_KEY=your_key_here
```

**Better: Use a config file (not in version control)**:

```dart
// config/secrets.dart (add to .gitignore)
class Secrets {
  static const String apiKey = 'your_api_key';
  static const String stripeKey = 'your_stripe_key';
}

// .gitignore
config/secrets.dart
```

---

### 3.2 HTTPS Only

```dart
class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com', // Always HTTPS
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    ),
  );
  
  ApiClient() {
    // Add interceptor to ensure HTTPS
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.uri.scheme.startsWith('https')) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Only HTTPS requests are allowed',
              ),
            );
          }
          return handler.next(options);
        },
      ),
    );
  }
}
```

---

### 3.3 Request Signing

```dart
class SecureApiClient {
  final String _apiKey;
  final String _apiSecret;
  
  SecureApiClient(this._apiKey, this._apiSecret);
  
  Future<Response> secureRequest(String endpoint, Map<String, dynamic> data) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();
    
    // Create signature
    final message = '$endpoint$timestamp$nonce${jsonEncode(data)}';
    final signature = _createSignature(message, _apiSecret);
    
    return await _dio.post(
      endpoint,
      data: data,
      options: Options(
        headers: {
          'X-API-Key': _apiKey,
          'X-Timestamp': timestamp,
          'X-Nonce': nonce,
          'X-Signature': signature,
        },
      ),
    );
  }
  
  String _createSignature(String message, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
  
  String _generateNonce() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
```

---

## 4. Data Protection

### 4.1 Encryption

```dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key _key;
  final IV _iv;
  final Encrypter _encrypter;
  
  EncryptionService(String keyString)
      : _key = Key.fromUtf8(keyString.padRight(32, '0').substring(0, 32)),
        _iv = IV.fromLength(16),
        _encrypter = Encrypter(AES(
          Key.fromUtf8(keyString.padRight(32, '0').substring(0, 32)),
        ));
  
  // Encrypt data
  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }
  
  // Decrypt data
  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}

// Usage
class UserDataService {
  final EncryptionService _encryption;
  
  Future<void> saveSensitiveData(String data) async {
    final encrypted = _encryption.encrypt(data);
    await _storage.write(key: 'sensitive_data', value: encrypted);
  }
  
  Future<String?> getSensitiveData() async {
    final encrypted = await _storage.read(key: 'sensitive_data');
    if (encrypted == null) return null;
    return _encryption.decrypt(encrypted);
  }
}
```

---

### 4.2 Certificate Pinning

```dart
class SecureHttpClient {
  static HttpClient createHttpClient() {
    final client = HttpClient();
    
    client.badCertificateCallback = (cert, host, port) {
      // Pin specific certificate
      final expectedSHA256 = 'YOUR_CERTIFICATE_SHA256_HASH';
      final certSHA256 = sha256.convert(cert.der).toString();
      
      return certSHA256 == expectedSHA256;
    };
    
    return client;
  }
}

// Usage with Dio
final dio = Dio();
dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: SecureHttpClient.createHttpClient,
);
```

---

## 5. OWASP Top 10

### 5.1 Mobile Security Risks

| Risk | Description | Mitigation |
|------|-------------|------------|
| **Improper Platform Usage** | Misuse of platform features | Follow platform guidelines |
| **Insecure Data Storage** | Storing sensitive data insecurely | Use encrypted storage |
| **Insecure Communication** | Unencrypted network traffic | Use HTTPS, certificate pinning |
| **Insecure Authentication** | Weak auth mechanisms | Use strong passwords, MFA |
| **Insufficient Cryptography** | Weak encryption | Use industry-standard algorithms |
| **Insecure Authorization** | Improper access control | Implement RBAC |
| **Client Code Quality** | Code vulnerabilities | Code review, static analysis |
| **Code Tampering** | App modification | Code obfuscation, integrity checks |
| **Reverse Engineering** | Extracting sensitive info | Obfuscation, ProGuard |
| **Extraneous Functionality** | Debug code in production | Remove debug code |

---

## 6. Common Vulnerabilities

### 6.1 SQL Injection (Backend)

```dart
// ❌ Bad - Vulnerable to SQL injection
class UserRepository {
  Future<User?> findByEmail(String email) async {
    final query = "SELECT * FROM users WHERE email = '$email'";
    // If email is: ' OR '1'='1
    // Query becomes: SELECT * FROM users WHERE email = '' OR '1'='1'
    // Returns all users!
  }
}

// ✅ Good - Use parameterized queries
class UserRepository {
  Future<User?> findByEmail(String email) async {
    final query = "SELECT * FROM users WHERE email = ?";
    final result = await db.query(query, [email]);
    // Email is properly escaped
  }
}
```

---

### 6.2 XSS (Cross-Site Scripting)

```dart
// ❌ Bad - Vulnerable to XSS
class CommentWidget extends StatelessWidget {
  final String comment;
  
  @override
  Widget build(BuildContext context) {
    return Html(data: comment); // Renders HTML directly!
    // If comment contains: <script>alert('XSS')</script>
    // It will execute!
  }
}

// ✅ Good - Sanitize input
class CommentWidget extends StatelessWidget {
  final String comment;
  
  @override
  Widget build(BuildContext context) {
    final sanitized = _sanitizeHtml(comment);
    return Text(sanitized); // Plain text, no HTML execution
  }
  
  String _sanitizeHtml(String html) {
    return html
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
```

---

### 6.3 Insecure Direct Object References

```dart
// ❌ Bad - No authorization check
class UserController {
  Future<Response> getUser(Request request) async {
    final userId = request.params['id'];
    final user = await _userRepository.findById(userId);
    // Any user can access any other user's data!
    return Response.ok(body: user.toJson());
  }
}

// ✅ Good - Check authorization
class UserController {
  Future<Response> getUser(Request request) async {
    final userId = request.params['id'];
    final currentUserId = request.context['userId'];
    
    // Check if user is accessing their own data or is admin
    if (userId != currentUserId && !_isAdmin(currentUserId)) {
      return Response.forbidden(body: {'error': 'Access denied'});
    }
    
    final user = await _userRepository.findById(userId);
    return Response.ok(body: user.toJson());
  }
}
```

---

### 6.4 Security Misconfiguration

```dart
// ❌ Bad - Debug mode in production
void main() {
  runApp(MyApp(debugMode: true)); // Exposes sensitive info
}

// ✅ Good - Disable debug in production
void main() {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  runApp(MyApp(debugMode: !isProduction));
}
```

---

### 6.5 Sensitive Data Exposure

```dart
// ❌ Bad - Logging sensitive data
class AuthService {
  Future<void> login(String email, String password) async {
    print('Login attempt: $email, $password'); // NEVER LOG PASSWORDS!
    // ...
  }
}

// ✅ Good - Don't log sensitive data
class AuthService {
  Future<void> login(String email, String password) async {
    print('Login attempt for user: $email'); // Only log non-sensitive info
    // ...
  }
}

// ❌ Bad - Exposing sensitive data in error messages
catch (e) {
  return Response.internalServerError(
    body: {'error': e.toString()} // May expose stack traces, DB info
  );
}

// ✅ Good - Generic error messages
catch (e) {
  _logger.error('Login failed', e); // Log internally
  return Response.internalServerError(
    body: {'error': 'An error occurred'} // Generic message to client
  );
}
```

---

### 6.6 Vulnerability Table

| Vulnerability | Risk Level | Example | Prevention |
|---------------|------------|---------|------------|
| **Hardcoded Secrets** | 🔴 Critical | API keys in code | Use environment variables |
| **Weak Passwords** | 🔴 Critical | "password123" | Enforce strong password policy |
| **No HTTPS** | 🔴 Critical | HTTP API calls | Always use HTTPS |
| **SQL Injection** | 🔴 Critical | Unescaped queries | Parameterized queries |
| **XSS** | 🟠 High | Unescaped HTML | Sanitize input |
| **CSRF** | 🟠 High | No token validation | Use CSRF tokens |
| **Insecure Storage** | 🟠 High | Plain text passwords | Encrypted storage |
| **Missing Auth** | 🟠 High | No login required | Implement authentication |
| **Weak Encryption** | 🟡 Medium | MD5 hashing | Use bcrypt, AES-256 |
| **Info Disclosure** | 🟡 Medium | Verbose errors | Generic error messages |

---

### 6.7 Security Checklist

```markdown
## Security Checklist

### Authentication
- [ ] Strong password requirements enforced
- [ ] Passwords hashed with bcrypt/Argon2
- [ ] Multi-factor authentication available
- [ ] Account lockout after failed attempts
- [ ] Secure password reset flow

### Authorization
- [ ] Role-based access control implemented
- [ ] Authorization checked on every request
- [ ] Principle of least privilege followed
- [ ] No client-side authorization only

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit (HTTPS)
- [ ] No sensitive data in logs
- [ ] Secure storage used for tokens/keys
- [ ] PII properly handled

### API Security
- [ ] All endpoints use HTTPS
- [ ] API keys not hardcoded
- [ ] Rate limiting implemented
- [ ] Input validation on all endpoints
- [ ] CORS properly configured

### Code Security
- [ ] No debug code in production
- [ ] Dependencies up to date
- [ ] Static analysis passing
- [ ] Code obfuscation enabled
- [ ] ProGuard rules configured

### Infrastructure
- [ ] Firewall rules configured
- [ ] Database access restricted
- [ ] Backups encrypted
- [ ] Monitoring and alerting set up
- [ ] Incident response plan documented
```

---

*Last Updated: November 2025*  
*Next: [8_TESTING.md](./8_TESTING.md)*
