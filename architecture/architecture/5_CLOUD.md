# 5. Cloud Architecture

## Table of Contents

1. [Firebase](#1-firebase)
2. [Cloud Platforms Comparison](#2-cloud-platforms-comparison)
3. [Serverless vs PaaS vs IaaS](#3-serverless-vs-paas-vs-iaas)
4. [CI/CD in the Cloud](#4-cicd-in-the-cloud)
5. [Cost Management](#5-cost-management)
6. [Security Best Practices](#6-security-best-practices)

---

## 1. Firebase

### 1.1 Firebase Services Overview

| Service | Purpose | Use Case |
|---------|---------|----------|
| **Authentication** | User authentication | Login, signup, social auth |
| **Firestore** | NoSQL database | Real-time data, offline support |
| **Realtime Database** | JSON database | Simple real-time sync |
| **Cloud Functions** | Serverless backend | API endpoints, triggers |
| **Cloud Storage** | File storage | Images, videos, documents |
| **Hosting** | Web hosting | Deploy web apps |
| **Analytics** | User analytics | Track user behavior |
| **Crashlytics** | Crash reporting | Monitor app stability |
| **Cloud Messaging** | Push notifications | Engage users |
| **Remote Config** | Feature flags | A/B testing, gradual rollout |

<!-- AI_NOTE: Firebase is ideal for rapid development and real-time features. It handles infrastructure so you can focus on app logic. -->

---

### 1.2 Firebase Authentication

**Implementation in Flutter**:

```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Email/Password Sign Up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      rethrow;
    }
  }

  
  // Email/Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      }
      rethrow;
    }
  }
  
  // Google Sign In
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }
  
  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
```

---

### 1.3 Firestore Database

**Best Practices**:

```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Read
  Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    
    if (!doc.exists) return null;
    
    return User.fromJson(doc.data()!);
  }
  
  // Update
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(userId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Delete
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
  
  // Query
  Future<List<User>> getActiveUsers() async {
    final query = await _firestore
        .collection('users')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    
    return query.docs
        .map((doc) => User.fromJson(doc.data()))
        .toList();
  }
  
  // Real-time listener
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => User.fromJson(doc.data()))
              .toList();
        });
  }
  
  // Batch write
  Future<void> batchCreateUsers(List<User> users) async {
    final batch = _firestore.batch();
    
    for (final user in users) {
      final ref = _firestore.collection('users').doc(user.id);
      batch.set(ref, user.toJson());
    }
    
    await batch.commit();
  }
}
```

---

### 1.4 Cloud Functions

**Use Cases**:
- API endpoints
- Database triggers
- Scheduled tasks
- Authentication triggers

**Example**:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// HTTP endpoint
exports.createUser = functions.https.onRequest(async (req, res) => {
  try {
    const { name, email } = req.body;
    
    const userRecord = await admin.auth().createUser({
      email: email,
      displayName: name,
    });
    
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      name: name,
      email: email,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    res.status(201).json({ userId: userRecord.uid });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Database trigger
exports.onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();
    
    // Send welcome email
    await sendWelcomeEmail(user.email, user.name);
    
    // Create default settings
    await admin.firestore()
      .collection('users')
      .doc(context.params.userId)
      .collection('settings')
      .doc('preferences')
      .set({
        theme: 'light',
        notifications: true,
      });
  });

// Scheduled function
exports.dailyCleanup = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - 30);
    
    const query = await admin.firestore()
      .collection('logs')
      .where('createdAt', '<', cutoff)
      .get();
    
    const batch = admin.firestore().batch();
    query.docs.forEach(doc => batch.delete(doc.ref));
    
    await batch.commit();
    
    console.log(`Deleted ${query.size} old logs`);
  });
```

---

## 2. Cloud Platforms Comparison

### 2.1 Firebase vs AWS vs GCP vs Supabase

| Feature | Firebase | AWS | GCP | Supabase |
|---------|----------|-----|-----|----------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Scalability** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Cost (Small)** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Cost (Large)** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Real-time** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **SQL Support** | ❌ | ✅ | ✅ | ✅ |
| **Open Source** | ❌ | ❌ | ❌ | ✅ |

---

## 3. Serverless vs PaaS vs IaaS

### 3.1 Comparison

**IaaS (Infrastructure as a Service)**:
- Raw servers, storage, networking
- Full control
- Most complex
- Examples: EC2, Compute Engine

**PaaS (Platform as a Service)**:
- Managed runtime environment
- Less control, easier management
- Examples: Heroku, App Engine

**Serverless (Function as a Service)**:
- No server management
- Pay per execution
- Auto-scaling
- Examples: Cloud Functions, Lambda

```
┌─────────────────────────────────────────────────────┐
│              RESPONSIBILITY MATRIX                  │
└─────────────────────────────────────────────────────┘

                    IaaS    PaaS    Serverless
Application         You     You     You
Runtime             You     Cloud   Cloud
OS                  You     Cloud   Cloud
Virtualization      Cloud   Cloud   Cloud
Servers             Cloud   Cloud   Cloud
Storage             Cloud   Cloud   Cloud
Networking          Cloud   Cloud   Cloud
```

---

### 3.2 When to Use Each

**Use Serverless when**:
- Unpredictable traffic
- Event-driven workloads
- Want minimal ops
- Cost optimization for low traffic

**Use PaaS when**:
- Standard web applications
- Want easy deployment
- Don't need full control
- Moderate traffic

**Use IaaS when**:
- Need full control
- Custom configurations
- Specific compliance needs
- Predictable, high traffic

---

## 4. CI/CD in the Cloud

### 4.1 GitHub Actions for Flutter

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
```

---

## 5. Cost Management

### 5.1 Firebase Pricing Optimization

**Tips**:

1. **Use Firestore efficiently**
   - Minimize reads with caching
   - Use pagination
   - Avoid unnecessary listeners

```dart
// ❌ Bad - Reads entire collection every time
Stream<List<User>> getUsers() {
  return _firestore.collection('users').snapshots().map(...);
}

// ✅ Good - Cache and paginate
class UserRepository {
  List<User>? _cachedUsers;
  DateTime? _lastFetch;
  
  Future<List<User>> getUsers() async {
    // Return cache if fresh
    if (_cachedUsers != null && 
        DateTime.now().difference(_lastFetch!) < Duration(minutes: 5)) {
      return _cachedUsers!;
    }
    
    // Fetch with limit
    final query = await _firestore
        .collection('users')
        .limit(50)
        .get();
    
    _cachedUsers = query.docs.map((doc) => User.fromJson(doc.data())).toList();
    _lastFetch = DateTime.now();
    
    return _cachedUsers!;
  }
}
```

2. **Optimize Cloud Functions**
   - Use appropriate memory allocation
   - Minimize cold starts
   - Use connection pooling

3. **Use CDN for static assets**
   - Reduce bandwidth costs
   - Improve performance

---

## 6. Security Best Practices

### 6.1 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles
      allow read: if true;
      
      // Only owner can update their profile
      allow update: if isOwner(userId);
      
      // Only admins can delete users
      allow delete: if isAdmin();
      
      // Subcollection for private data
      match /private/{document=**} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // Posts collection
    match /posts/{postId} {
      // Anyone can read posts
      allow read: if true;
      
      // Authenticated users can create posts
      allow create: if isAuthenticated() && 
                       request.resource.data.authorId == request.auth.uid;
      
      // Only author can update/delete
      allow update, delete: if isAuthenticated() && 
                               resource.data.authorId == request.auth.uid;
    }
  }
}
```

---

### 6.2 Cloud Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│              CLOUD ARCHITECTURE EXAMPLE                 │
└─────────────────────────────────────────────────────────┘

┌──────────────┐
│ Flutter App  │
└──────┬───────┘
       │ HTTPS
       │
┌──────▼───────────────────────────────────────────────┐
│              Firebase / Cloud Platform               │
│                                                      │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │   Auth     │  │  Firestore │  │   Storage    │  │
│  │            │  │            │  │              │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
│                                                      │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │  Functions │  │  Analytics │  │ Crashlytics  │  │
│  │            │  │            │  │              │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
│                                                      │
└──────────────────────────────────────────────────────┘
       │
       │ Integrations
       │
┌──────▼───────────────────────────────────────────────┐
│           External Services                          │
│                                                      │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │  Stripe    │  │  SendGrid  │  │   Twilio     │  │
│  │  Payment   │  │   Email    │  │    SMS       │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

*Last Updated: November 2025*  
*Next: [6_DEVOPS.md](./6_DEVOPS.md)*
