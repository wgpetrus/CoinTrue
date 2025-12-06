# 2. System Design

## Table of Contents

1. [System Architecture Fundamentals](#1-system-architecture-fundamentals)
2. [Communication Protocols](#2-communication-protocols)
3. [Scalability](#3-scalability)
4. [Database Design](#4-database-design)
5. [Caching Strategies](#5-caching-strategies)
6. [System Design Patterns](#6-system-design-patterns)

---

## 1. System Architecture Fundamentals

### 1.1 Basic System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    TYPICAL SYSTEM ARCHITECTURE               │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐
│   Client     │  (Flutter App, Web Browser)
│  (Frontend)  │
└──────┬───────┘
       │
       │ HTTPS
       │
┌──────▼───────┐
│     CDN      │  (Static Assets, Images)
└──────────────┘
       │
┌──────▼───────┐
│ Load Balancer│  (Distributes traffic)
└──────┬───────┘
       │
   ┌───┴───┬───────┬───────┐
   │       │       │       │
┌──▼───┐┌──▼───┐┌──▼───┐┌──▼───┐
│ API  ││ API  ││ API  ││ API  │  (Backend Servers)
│Server││Server││Server││Server│
└──┬───┘└──┬───┘└──┬───┘└──┬───┘
   │       │       │       │
   └───┬───┴───┬───┴───┬───┘
       │       │       │
   ┌───▼───────▼───────▼───┐
   │      Database          │  (PostgreSQL, MongoDB)
   └────────────────────────┘
       │
   ┌───▼────────────────────┐
   │   Cache (Redis)        │
   └────────────────────────┘
       │
   ┌───▼────────────────────┐
   │  Message Queue         │  (RabbitMQ, Kafka)
   └────────────────────────┘
```

<!-- AI_NOTE: This is a standard architecture. Frontend talks to backend via API, backend handles business logic and data access. -->

---

### 1.2 Frontend Architecture

**Responsibilities**:
- User interface rendering
- User input handling
- Client-side validation
- State management
- API communication
- Local caching

**Flutter-specific considerations**:
- Platform-specific code (iOS/Android)
- Widget tree optimization
- Asset management
- Navigation
- Offline-first capabilities

---

### 1.3 Backend Architecture Layers

```
┌─────────────────────────────────────────┐
│         BACKEND ARCHITECTURE            │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Presentation Layer (Controllers/API)   │  ← HTTP Requests
│  - Route handling                       │
│  - Request validation                   │
│  - Response formatting                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Business Logic Layer (Services)        │
│  - Business rules                       │
│  - Use case orchestration               │
│  - Transaction management               │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Data Access Layer (Repositories)       │
│  - Database queries                     │
│  - Data mapping                         │
│  - Cache management                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Database Layer                         │
│  - Data persistence                     │
│  - Relationships                        │
│  - Constraints                          │
└─────────────────────────────────────────┘
```

<!-- AI_NOTE: Each layer has a specific responsibility. Controllers handle HTTP, Services handle business logic, Repositories handle data access. -->

---

## 2. Communication Protocols

### 2.1 REST API

**Principles**:
- Stateless communication
- Resource-based URLs
- Standard HTTP methods
- JSON data format

**HTTP Methods**:

| Method | Purpose | Example | Idempotent |
|--------|---------|---------|------------|
| GET | Retrieve data | `GET /users/123` | Yes |
| POST | Create resource | `POST /users` | No |
| PUT | Update/Replace | `PUT /users/123` | Yes |
| PATCH | Partial update | `PATCH /users/123` | No |
| DELETE | Delete resource | `DELETE /users/123` | Yes |

**Status Codes**:

| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | No permission |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Internal error |

#### ✅ Good REST API Design

```dart
// Flutter API Client
class UserApiClient {
  final Dio _dio;
  
  UserApiClient(this._dio);
  
  // GET /api/v1/users
  Future<List<User>> getUsers() async {
    final response = await _dio.get('/api/v1/users');
    return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
  }
  
  // GET /api/v1/users/:id
  Future<User> getUser(String id) async {
    final response = await _dio.get('/api/v1/users/$id');
    return User.fromJson(response.data);
  }
  
  // POST /api/v1/users
  Future<User> createUser(CreateUserRequest request) async {
    final response = await _dio.post(
      '/api/v1/users',
      data: request.toJson(),
    );
    return User.fromJson(response.data);
  }
  
  // PUT /api/v1/users/:id
  Future<User> updateUser(String id, UpdateUserRequest request) async {
    final response = await _dio.put(
      '/api/v1/users/$id',
      data: request.toJson(),
    );
    return User.fromJson(response.data);
  }
  
  // DELETE /api/v1/users/:id
  Future<void> deleteUser(String id) async {
    await _dio.delete('/api/v1/users/$id');
  }
}
```

#### ❌ Bad REST API Design

```dart
// Inconsistent, non-RESTful endpoints
POST /getUserById
POST /createNewUser
GET /deleteUser?id=123
POST /updateUserData
```

---

### 2.2 GraphQL

**When to use**: When clients need flexible data fetching, avoiding over-fetching or under-fetching.

**Advantages**:
- Single endpoint
- Client specifies exact data needed
- Strong typing
- Real-time subscriptions

**Disadvantages**:
- More complex to implement
- Caching is harder
- Can be overkill for simple APIs

**Example**:

```graphql
# Query
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    email
    posts {
      id
      title
    }
  }
}

# Mutation
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    name
    email
  }
}
```

**Flutter Implementation**:

```dart
class GraphQLService {
  final GraphQLClient _client;
  
  GraphQLService(this._client);
  
  Future<User> getUser(String id) async {
    const query = r'''
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          name
          email
        }
      }
    ''';
    
    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: {'id': id},
      ),
    );
    
    if (result.hasException) {
      throw result.exception!;
    }
    
    return User.fromJson(result.data!['user']);
  }
}
```

---

### 2.3 WebSockets

**When to use**: Real-time, bidirectional communication (chat, live updates, gaming).

**Flutter Implementation**:

```dart
class WebSocketService {
  IOWebSocketChannel? _channel;
  final StreamController<String> _messageController = StreamController.broadcast();
  
  Stream<String> get messages => _messageController.stream;
  
  void connect(String url) {
    _channel = IOWebSocketChannel.connect(url);
    
    _channel!.stream.listen(
      (message) {
        _messageController.add(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }
  
  void send(String message) {
    _channel?.sink.add(message);
  }
  
  void disconnect() {
    _channel?.sink.close();
    _messageController.close();
  }
}
```

---

## 3. Scalability

### 3.1 Horizontal vs Vertical Scaling

**Vertical Scaling (Scale Up)**:
- Add more resources to existing server (CPU, RAM)
- Simpler to implement
- Has limits
- Single point of failure

**Horizontal Scaling (Scale Out)**:
- Add more servers
- Better fault tolerance
- Unlimited scaling potential
- Requires load balancing

```
VERTICAL SCALING              HORIZONTAL SCALING
     
┌─────────┐                  ┌─────┐ ┌─────┐ ┌─────┐
│ Server  │                  │ S1  │ │ S2  │ │ S3  │
│ 32GB RAM│                  │ 8GB │ │ 8GB │ │ 8GB │
│ 16 CPU  │                  │ 4CPU│ │ 4CPU│ │ 4CPU│
└─────────┘                  └─────┘ └─────┘ └─────┘
     ↑                             ↑
  Upgrade                    Add more servers
```

<!-- AI_NOTE: Prefer horizontal scaling for production systems. It's more resilient and cost-effective at scale. -->

---

### 3.2 Load Balancing

**Purpose**: Distribute traffic across multiple servers.

**Strategies**:

1. **Round Robin**: Distribute requests evenly
2. **Least Connections**: Send to server with fewest active connections
3. **IP Hash**: Same client always goes to same server
4. **Weighted**: Distribute based on server capacity

```
                ┌──────────────┐
                │Load Balancer │
                └──────┬───────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    ┌───▼───┐      ┌───▼───┐      ┌───▼───┐
    │Server1│      │Server2│      │Server3│
    └───────┘      └───────┘      └───────┘
```

---

### 3.3 Caching

**Levels of Caching**:

1. **Client-side** (Flutter app)
2. **CDN** (Static assets)
3. **Application** (Redis, Memcached)
4. **Database** (Query cache)

**Cache Strategies**:

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Cache-Aside** | App checks cache, loads from DB if miss | General purpose |
| **Write-Through** | Write to cache and DB simultaneously | Data consistency |
| **Write-Behind** | Write to cache, async write to DB | High write throughput |
| **Refresh-Ahead** | Proactively refresh before expiry | Predictable access patterns |

**Flutter Caching Example**:

```dart
class CachedUserRepository implements UserRepository {
  final UserApiClient _apiClient;
  final Map<String, User> _cache = {};
  final Duration _cacheDuration = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};
  
  CachedUserRepository(this._apiClient);
  
  @override
  Future<User> getUser(String id) async {
    // Check if cached and not expired
    if (_cache.containsKey(id)) {
      final timestamp = _cacheTimestamps[id]!;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return _cache[id]!; // Return cached
      }
    }
    
    // Fetch from API
    final user = await _apiClient.getUser(id);
    
    // Update cache
    _cache[id] = user;
    _cacheTimestamps[id] = DateTime.now();
    
    return user;
  }
  
  void invalidateCache(String id) {
    _cache.remove(id);
    _cacheTimestamps.remove(id);
  }
}
```

---

## 4. Database Design

### 4.1 SQL vs NoSQL

| Aspect | SQL (Relational) | NoSQL (Non-Relational) |
|--------|------------------|------------------------|
| **Schema** | Fixed, predefined | Flexible, dynamic |
| **Scaling** | Vertical (harder) | Horizontal (easier) |
| **Transactions** | ACID compliant | Eventually consistent |
| **Relationships** | Strong, via joins | Weak, denormalized |
| **Use Cases** | Financial, complex queries | Real-time, high volume |
| **Examples** | PostgreSQL, MySQL | MongoDB, Firestore |

<!-- AI_NOTE: Choose SQL for complex relationships and transactions. Choose NoSQL for flexibility and horizontal scaling. -->

---

### 4.2 Database Normalization

**Purpose**: Reduce data redundancy and improve integrity.

**Normal Forms**:

**1NF (First Normal Form)**:
- Atomic values (no arrays or nested objects)
- Each column has unique name
- Order doesn't matter

**2NF (Second Normal Form)**:
- Must be in 1NF
- No partial dependencies

**3NF (Third Normal Form)**:
- Must be in 2NF
- No transitive dependencies

#### ❌ Bad (Denormalized)

```sql
-- Orders table with redundant customer data
CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  customer_email VARCHAR(100),
  customer_address VARCHAR(200),
  product_name VARCHAR(100),
  quantity INT,
  price DECIMAL
);
```

#### ✅ Good (Normalized)

```sql
-- Customers table
CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  address VARCHAR(200)
);

-- Products table
CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL
);

-- Orders table (references only)
CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_id INT REFERENCES customers(id),
  product_id INT REFERENCES products(id),
  quantity INT,
  created_at TIMESTAMP
);
```

---

### 4.3 Indexing

**Purpose**: Speed up data retrieval.

**When to Index**:
- Columns used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY
- Foreign keys

**When NOT to Index**:
- Small tables
- Columns with low cardinality (few unique values)
- Frequently updated columns

```sql
-- Create index on email for faster lookups
CREATE INDEX idx_users_email ON users(email);

-- Composite index for common query patterns
CREATE INDEX idx_orders_customer_date ON orders(customer_id, created_at);
```

---

### 4.4 Firestore Data Modeling

**Best Practices**:

1. **Denormalize for reads**: Duplicate data to avoid joins
2. **Use subcollections**: For one-to-many relationships
3. **Limit nesting**: Max 1 level of subcollections for queries
4. **Use document references**: For many-to-many relationships

#### ✅ Good Firestore Structure

```
users (collection)
  └── userId (document)
      ├── name: "John Doe"
      ├── email: "john@example.com"
      └── posts (subcollection)
          └── postId (document)
              ├── title: "My Post"
              ├── content: "..."
              └── createdAt: timestamp

posts (collection) - Denormalized for listing
  └── postId (document)
      ├── title: "My Post"
      ├── content: "..."
      ├── authorId: "userId"
      ├── authorName: "John Doe" (denormalized)
      └── createdAt: timestamp
```

**Flutter Firestore Example**:

```dart
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<User> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    
    if (!doc.exists) {
      throw Exception('User not found');
    }
    
    return User.fromJson(doc.data()!);
  }
  
  @override
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
  
  @override
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => User.fromJson(doc.data()))
              .toList();
        });
  }
}
```

---

## 5. Caching Strategies

### 5.1 Cache Invalidation

**Strategies**:

1. **Time-based (TTL)**: Cache expires after fixed time
2. **Event-based**: Invalidate on data change
3. **Manual**: Explicit cache clear

```dart
class SmartCache<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration ttl;
  
  SmartCache({required this.ttl});
  
  void set(String key, T value) {
    _cache[key] = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
    );
  }
  
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (DateTime.now().difference(entry.timestamp) > ttl) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value;
  }
  
  void invalidate(String key) {
    _cache.remove(key);
  }
  
  void clear() {
    _cache.clear();
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime timestamp;
  
  CacheEntry({required this.value, required this.timestamp});
}
```

---

## 6. System Design Patterns

### 6.1 Microservices vs Monolith

**Monolith**:
```
┌─────────────────────────────┐
│      Single Application     │
│  ┌────────┬────────┬──────┐ │
│  │ Auth   │Products│Orders│ │
│  └────────┴────────┴──────┘ │
└─────────────┬───────────────┘
              │
        ┌─────▼─────┐
        │ Database  │
        └───────────┘
```

**Microservices**:
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  Auth    │  │ Products │  │  Orders  │
│ Service  │  │ Service  │  │ Service  │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
┌────▼────┐   ┌────▼────┐   ┌────▼────┐
│Auth DB  │   │Prod DB  │   │Order DB │
└─────────┘   └─────────┘   └─────────┘
```

| Aspect | Monolith | Microservices |
|--------|----------|---------------|
| **Complexity** | Low | High |
| **Deployment** | Simple | Complex |
| **Scaling** | All or nothing | Independent |
| **Development** | Easier initially | Harder coordination |
| **Best for** | Small teams, MVPs | Large teams, scale |

<!-- AI_NOTE: Start with monolith. Move to microservices only when you have clear scaling or team organization needs. -->

---

*Last Updated: November 2025*  
*Next: [3_SOFTWARE_ARCHITECT_ROLE.md](./3_SOFTWARE_ARCHITECT_ROLE.md)*
