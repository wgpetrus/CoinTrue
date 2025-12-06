# 4. Backend Architecture

## Table of Contents

1. [Backend Layers](#1-backend-layers)
2. [API Design](#2-api-design)
3. [Authentication & Authorization](#3-authentication--authorization)
4. [Data Consistency](#4-data-consistency)
5. [Firebase vs Custom API](#5-firebase-vs-custom-api)
6. [Scalability Strategies](#6-scalability-strategies)

---

## 1. Backend Layers

### 1.1 Controller Layer

**Responsibility**: Handle HTTP requests and responses.

```dart
// Example: Node.js/Express-style controller
class UserController {
  final UserService _userService;
  
  UserController(this._userService);
  
  Future<Response> getUser(Request request) async {
    try {
      final userId = request.params['id'];
      
      // Validation
      if (userId == null || userId.isEmpty) {
        return Response.badRequest(body: {'error': 'User ID is required'});
      }
      
      // Delegate to service layer
      final user = await _userService.getUser(userId);
      
      // Format response
      return Response.ok(body: user.toJson());
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  }
  
  Future<Response> createUser(Request request) async {
    try {
      final body = await request.readAsJson();
      
      // Validation
      if (!_isValidUserData(body)) {
        return Response.badRequest(body: {'error': 'Invalid user data'});
      }
      
      // Delegate to service
      final user = await _userService.createUser(body);
      
      return Response.created(body: user.toJson());
    } catch (e) {
      return Response.internalServerError(body: {'error': e.toString()});
    }
  }
}
```

<!-- AI_NOTE: Controllers should be thin. They validate input, call services, and format responses. No business logic here. -->

---

### 1.2 Service Layer

**Responsibility**: Business logic and use case orchestration.

```dart
class UserService {
  final UserRepository _userRepository;
  final EmailService _emailService;
  final AnalyticsService _analyticsService;
  
  UserService(
    this._userRepository,
    this._emailService,
    this._analyticsService,
  );
  
  Future<User> createUser(CreateUserDto dto) async {
    // Validation
    if (!_isValidEmail(dto.email)) {
      throw ValidationException('Invalid email format');
    }
    
    // Check if user exists
    final existingUser = await _userRepository.findByEmail(dto.email);
    if (existingUser != null) {
      throw ConflictException('User already exists');
    }
    
    // Create user
    final user = User(
      id: _generateId(),
      name: dto.name,
      email: dto.email,
      createdAt: DateTime.now(),
    );
    
    // Save to database
    await _userRepository.save(user);
    
    // Send welcome email (async, don't wait)
    _emailService.sendWelcomeEmail(user).catchError((e) {
      // Log error but don't fail the request
      print('Failed to send welcome email: $e');
    });
    
    // Track analytics
    await _analyticsService.trackEvent('user_created', {
      'userId': user.id,
      'email': user.email,
    });
    
    return user;
  }
  
  Future<User> getUser(String userId) async {
    final user = await _userRepository.findById(userId);
    
    if (user == null) {
      throw NotFoundException('User not found');
    }
    
    return user;
  }
}
```

<!-- AI_NOTE: Services contain business logic. They orchestrate multiple repositories and external services. Keep controllers thin. -->

---

### 1.3 Repository Layer

**Responsibility**: Data access and persistence.

```dart
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<User?> findByEmail(String email);
  Future<List<User>> findAll();
  Future<void> save(User user);
  Future<void> update(User user);
  Future<void> delete(String id);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  
  FirestoreUserRepository(this._firestore);
  
  @override
  Future<User?> findById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return User.fromJson(doc.data()!);
  }
  
  @override
  Future<User?> findByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) {
      return null;
    }
    
    return User.fromJson(query.docs.first.data());
  }
  
  @override
  Future<void> save(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
  
  @override
  Future<void> update(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }
  
  @override
  Future<void> delete(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }
}
```

---

## 2. API Design

### 2.1 RESTful API Best Practices

**URL Structure**:

```
✅ Good:
GET    /api/v1/users              - List users
GET    /api/v1/users/:id          - Get user
POST   /api/v1/users              - Create user
PUT    /api/v1/users/:id          - Update user
DELETE /api/v1/users/:id          - Delete user
GET    /api/v1/users/:id/posts    - Get user's posts

❌ Bad:
GET    /api/getUsers
POST   /api/createUser
GET    /api/user?action=delete&id=123
```

**Request/Response Format**:

```json
// POST /api/v1/users - Create User Request
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123"
}

// Response - 201 Created
{
  "id": "user_123",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2025-11-28T10:00:00Z"
}

// Error Response - 400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "invalid-email"
    }
  }
}
```

---

### 2.2 API Versioning

**Why Version**:
- Maintain backward compatibility
- Allow gradual migration
- Support multiple clients

**Strategies**:

1. **URL Versioning** (Recommended)
```
/api/v1/users
/api/v2/users
```

2. **Header Versioning**
```
GET /api/users
Accept: application/vnd.myapi.v1+json
```

3. **Query Parameter**
```
/api/users?version=1
```

---

### 2.3 Pagination

**Cursor-based Pagination** (Recommended for large datasets):

```dart
// Request
GET /api/v1/posts?limit=20&cursor=abc123

// Response
{
  "data": [...],
  "pagination": {
    "nextCursor": "xyz789",
    "hasMore": true
  }
}

// Flutter Implementation
class PostApiClient {
  Future<PaginatedResponse<Post>> getPosts({
    int limit = 20,
    String? cursor,
  }) async {
    final response = await _dio.get(
      '/api/v1/posts',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    
    return PaginatedResponse.fromJson(
      response.data,
      (json) => Post.fromJson(json),
    );
  }
}
```

**Offset-based Pagination** (Simpler, but less efficient):

```dart
// Request
GET /api/v1/posts?page=2&limit=20

// Response
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

---

### 2.4 Filtering and Sorting

```dart
// Request
GET /api/v1/products?category=electronics&minPrice=100&sort=-price

// Flutter Implementation
class ProductApiClient {
  Future<List<Product>> getProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (category != null) queryParams['category'] = category;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sort'] = sortBy;
    
    final response = await _dio.get(
      '/api/v1/products',
      queryParameters: queryParams,
    );
    
    return (response.data as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
}
```

---

## 3. Authentication & Authorization

### 3.1 JWT Authentication Flow

```
┌──────────┐                                    ┌──────────┐
│  Client  │                                    │  Server  │
└────┬─────┘                                    └────┬─────┘
     │                                               │
     │  1. POST /auth/login                          │
     │     { email, password }                       │
     ├──────────────────────────────────────────────>│
     │                                               │
     │                                2. Verify      │
     │                                credentials    │
     │                                               │
     │  3. Return JWT token                          │
     │<──────────────────────────────────────────────┤
     │     { token: "eyJhbG..." }                    │
     │                                               │
     │  4. GET /api/users                            │
     │     Authorization: Bearer eyJhbG...           │
     ├──────────────────────────────────────────────>│
     │                                               │
     │                                5. Verify      │
     │                                token          │
     │                                               │
     │  6. Return data                               │
     │<──────────────────────────────────────────────┤
     │                                               │
```

**Flutter Implementation**:

```dart
class AuthService {
  final ApiClient _apiClient;
  final SecureStorage _storage;
  
  String? _token;
  
  AuthService(this._apiClient, this._storage);
  
  Future<void> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    
    _token = response.data['token'];
    
    // Store token securely
    await _storage.write(key: 'auth_token', value: _token);
    
    // Set token in API client
    _apiClient.setAuthToken(_token!);
  }
  
  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'auth_token');
    _apiClient.clearAuthToken();
  }
  
  Future<bool> isAuthenticated() async {
    if (_token != null) return true;
    
    // Try to load from storage
    _token = await _storage.read(key: 'auth_token');
    
    if (_token != null) {
      _apiClient.setAuthToken(_token!);
      return true;
    }
    
    return false;
  }
}
```

---

### 3.2 Role-Based Access Control (RBAC)

```dart
enum UserRole {
  admin,
  moderator,
  user,
}

class User {
  final String id;
  final String email;
  final UserRole role;
  
  User({required this.id, required this.email, required this.role});
  
  bool hasPermission(Permission permission) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin has all permissions
      case UserRole.moderator:
        return permission != Permission.deleteUser;
      case UserRole.user:
        return permission == Permission.viewContent;
    }
  }
}

enum Permission {
  viewContent,
  createContent,
  editContent,
  deleteContent,
  deleteUser,
}

// Usage in UI
class AdminPanel extends StatelessWidget {
  final User currentUser;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (currentUser.hasPermission(Permission.createContent))
          ElevatedButton(
            onPressed: () => _createContent(),
            child: Text('Create Content'),
          ),
        if (currentUser.hasPermission(Permission.deleteUser))
          ElevatedButton(
            onPressed: () => _deleteUser(),
            child: Text('Delete User'),
          ),
      ],
    );
  }
}
```

---

## 4. Data Consistency

### 4.1 Transactions

**When to use**:
- Multiple related operations must succeed or fail together
- Financial operations
- Inventory management

**Example**:

```dart
class OrderService {
  final FirebaseFirestore _firestore;
  
  Future<void> createOrder(Order order) async {
    // Use transaction to ensure consistency
    await _firestore.runTransaction((transaction) async {
      // 1. Check product availability
      final productRef = _firestore.collection('products').doc(order.productId);
      final productDoc = await transaction.get(productRef);
      
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }
      
      final product = Product.fromJson(productDoc.data()!);
      
      if (product.stock < order.quantity) {
        throw Exception('Insufficient stock');
      }
      
      // 2. Create order
      final orderRef = _firestore.collection('orders').doc();
      transaction.set(orderRef, order.toJson());
      
      // 3. Update product stock
      transaction.update(productRef, {
        'stock': product.stock - order.quantity,
      });
      
      // All operations succeed or all fail
    });
  }
}
```

---

### 4.2 Optimistic vs Pessimistic Locking

**Optimistic Locking**: Assume no conflicts, check before committing

```dart
class DocumentService {
  Future<void> updateDocument(Document doc) async {
    final ref = _firestore.collection('documents').doc(doc.id);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final currentVersion = snapshot.data()!['version'];
      
      // Check if version matches (no one else updated it)
      if (currentVersion != doc.version) {
        throw Exception('Document was modified by another user');
      }
      
      // Update with new version
      transaction.update(ref, {
        ...doc.toJson(),
        'version': doc.version + 1,
      });
    });
  }
}
```

**Pessimistic Locking**: Lock resource before modifying

```dart
// Using distributed lock (e.g., Redis)
class InventoryService {
  final RedisClient _redis;
  
  Future<void> updateStock(String productId, int quantity) async {
    final lockKey = 'lock:product:$productId';
    
    // Acquire lock
    final acquired = await _redis.setNX(lockKey, '1', duration: Duration(seconds: 10));
    
    if (!acquired) {
      throw Exception('Resource is locked');
    }
    
    try {
      // Perform update
      await _updateStockInDatabase(productId, quantity);
    } finally {
      // Release lock
      await _redis.delete(lockKey);
    }
  }
}
```

---

## 5. Firebase vs Custom API

### 5.1 Comparison

| Aspect | Firebase | Custom API |
|--------|----------|------------|
| **Setup Time** | Minutes | Days/Weeks |
| **Scalability** | Automatic | Manual configuration |
| **Cost** | Pay-as-you-go | Server costs + maintenance |
| **Flexibility** | Limited | Full control |
| **Real-time** | Built-in | Need to implement |
| **Offline Support** | Built-in | Need to implement |
| **Complex Queries** | Limited | Full SQL/NoSQL |
| **Custom Logic** | Cloud Functions | Full backend |

---

### 5.2 When to Use Firebase

**Use Firebase when**:
- Rapid prototyping/MVP
- Real-time features needed
- Small to medium scale
- Limited backend resources
- Mobile-first application
- Need offline support

**Example Use Cases**:
- Chat applications
- Social media apps
- Collaborative tools
- Consumer mobile apps

---

### 5.3 When to Use Custom API

**Use Custom API when**:
- Complex business logic
- Advanced queries needed
- Integration with existing systems
- Specific compliance requirements
- Need full control
- Large scale with specific needs

**Example Use Cases**:
- Enterprise applications
- E-commerce platforms
- Financial systems
- Healthcare applications

---

### 5.4 Hybrid Approach

**Best of both worlds**:

```
┌──────────────┐
│ Flutter App  │
└──────┬───────┘
       │
   ┌───┴────┬──────────────┐
   │        │              │
┌──▼────┐ ┌─▼────────┐ ┌──▼──────┐
│Firebase│ │Custom API│ │ Stripe  │
│        │ │          │ │ Payment │
│- Auth  │ │- Complex │ └─────────┘
│- Storage│ │  queries │
│- Real  │ │- Business│
│  time  │ │  logic   │
└────────┘ └──────────┘
```

**Example**:

```dart
class HybridDataService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final CustomApiClient _apiClient;
  
  // Use Firebase for authentication
  Future<User> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return User.fromFirebase(credential.user!);
  }
  
  // Use Firebase for real-time chat
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList();
        });
  }
  
  // Use Custom API for complex business logic
  Future<OrderSummary> createOrder(Order order) async {
    return await _apiClient.createOrder(order);
  }
  
  // Use Custom API for advanced queries
  Future<List<Product>> searchProducts(SearchCriteria criteria) async {
    return await _apiClient.searchProducts(criteria);
  }
}
```

---

## 6. Scalability Strategies

### 6.1 Caching

**Levels**:

1. **Client-side** (Flutter app memory)
2. **CDN** (Static assets)
3. **Application cache** (Redis)
4. **Database cache** (Query results)

```dart
class CachedProductRepository implements ProductRepository {
  final ProductApiClient _apiClient;
  final CacheManager _cache;
  
  @override
  Future<Product> getProduct(String id) async {
    // Try cache first
    final cached = await _cache.get('product:$id');
    if (cached != null) {
      return Product.fromJson(jsonDecode(cached));
    }
    
    // Fetch from API
    final product = await _apiClient.getProduct(id);
    
    // Cache for 5 minutes
    await _cache.set(
      'product:$id',
      jsonEncode(product.toJson()),
      ttl: Duration(minutes: 5),
    );
    
    return product;
  }
}
```

---

### 6.2 Rate Limiting

**Purpose**: Prevent abuse and ensure fair usage.

```dart
class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final int maxRequests;
  final Duration window;
  
  RateLimiter({
    required this.maxRequests,
    required this.window,
  });
  
  bool allowRequest(String userId) {
    final now = DateTime.now();
    final userRequests = _requests[userId] ?? [];
    
    // Remove old requests outside the window
    userRequests.removeWhere((time) {
      return now.difference(time) > window;
    });
    
    // Check if limit exceeded
    if (userRequests.length >= maxRequests) {
      return false;
    }
    
    // Add current request
    userRequests.add(now);
    _requests[userId] = userRequests;
    
    return true;
  }
}

// Usage in API client
class ApiClient {
  final RateLimiter _rateLimiter = RateLimiter(
    maxRequests: 100,
    window: Duration(minutes: 1),
  );
  
  Future<Response> request(String endpoint) async {
    final userId = await _getCurrentUserId();
    
    if (!_rateLimiter.allowRequest(userId)) {
      throw RateLimitException('Too many requests');
    }
    
    return await _dio.get(endpoint);
  }
}
```

---

### 6.3 Async Processing

**Use queues for long-running tasks**:

```dart
class OrderService {
  final OrderRepository _orderRepository;
  final MessageQueue _queue;
  
  Future<Order> createOrder(CreateOrderDto dto) async {
    // Create order immediately
    final order = Order.fromDto(dto);
    await _orderRepository.save(order);
    
    // Queue async tasks (don't wait)
    await _queue.publish('order.created', {
      'orderId': order.id,
      'userId': order.userId,
    });
    
    // These will be processed asynchronously:
    // - Send confirmation email
    // - Update inventory
    // - Notify warehouse
    // - Update analytics
    
    return order;
  }
}
```

---

*Last Updated: November 2025*  
*Next: [5_CLOUD.md](./5_CLOUD.md)*
