# 📚 API & Architecture Documentation

## Project Architecture

This application follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Pages, Widgets, UI Components)        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Business Logic Layer           │
│     (Services, State Management)        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│            Data Layer                   │
│  (Models, Firebase, Data Sources)       │
└─────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
lib/
├── models/                    # Data models
│   └── infrastructure_model.dart
├── services/                  # Business logic
│   ├── auth_service.dart
│   └── firebase_service.dart
├── pages/                     # UI screens
│   ├── login_page.dart
│   ├── dashboard_page.dart
│   ├── infrastructure_list_page.dart
│   ├── add_infrastructure_page.dart
│   ├── edit_infrastructure_page.dart
│   ├── asset_detail_page.dart
│   └── analytics_page.dart
├── widgets/                   # Reusable components
│   ├── sidebar.dart
│   ├── dashboard_cards.dart
│   ├── charts.dart
│   └── common_widgets.dart
└── main.dart                  # App entry point
```

---

## 🔐 Authentication Service

### AuthService Class

**Location**: `lib/services/auth_service.dart`

#### Methods

##### `signIn(String email, String password)`
Authenticates user with email and password.

**Parameters:**
- `email`: User email address
- `password`: User password

**Returns:** `Future<UserCredential>`

**Example:**
```dart
final authService = AuthService();
await authService.signIn('admin@smartcity.com', 'password123');
```

##### `signOut()`
Signs out the current user.

**Returns:** `Future<void>`

**Example:**
```dart
await authService.signOut();
```

##### `currentUser`
Gets the currently authenticated user.

**Returns:** `User?`

**Example:**
```dart
final user = authService.currentUser;
if (user != null) {
  print('Logged in as: ${user.email}');
}
```

##### `authStateChanges`
Stream of authentication state changes.

**Returns:** `Stream<User?>`

**Example:**
```dart
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User logged in');
  } else {
    print('User logged out');
  }
});
```

---

## 🔥 Firebase Service

### FirebaseService Class

**Location**: `lib/services/firebase_service.dart`

#### Methods

##### `getAssets()`
Retrieves all infrastructure assets as a stream.

**Returns:** `Stream<List<InfrastructureAsset>>`

**Example:**
```dart
final firebaseService = FirebaseService();
firebaseService.getAssets().listen((assets) {
  print('Total assets: ${assets.length}');
});
```

##### `getAsset(String id)`
Retrieves a single asset by ID.

**Parameters:**
- `id`: Asset document ID

**Returns:** `Future<InfrastructureAsset?>`

**Example:**
```dart
final asset = await firebaseService.getAsset('asset123');
if (asset != null) {
  print('Asset name: ${asset.name}');
}
```

##### `addAsset(InfrastructureAsset asset)`
Adds a new infrastructure asset.

**Parameters:**
- `asset`: InfrastructureAsset object

**Returns:** `Future<void>`

**Example:**
```dart
final newAsset = InfrastructureAsset(
  name: 'Main Bridge',
  type: 'Bridge',
  location: 'Downtown',
  status: 'Good',
  description: 'Main river crossing',
  lastInspectionDate: DateTime.now(),
  createdAt: DateTime.now(),
);
await firebaseService.addAsset(newAsset);
```

##### `updateAsset(String id, InfrastructureAsset asset)`
Updates an existing asset.

**Parameters:**
- `id`: Asset document ID
- `asset`: Updated InfrastructureAsset object

**Returns:** `Future<void>`

**Example:**
```dart
await firebaseService.updateAsset('asset123', updatedAsset);
```

##### `deleteAsset(String id)`
Deletes an asset.

**Parameters:**
- `id`: Asset document ID

**Returns:** `Future<void>`

**Example:**
```dart
await firebaseService.deleteAsset('asset123');
```

##### `searchAssets(String query)`
Searches assets by name or location.

**Parameters:**
- `query`: Search query string

**Returns:** `Stream<List<InfrastructureAsset>>`

**Example:**
```dart
firebaseService.searchAssets('bridge').listen((results) {
  print('Found ${results.length} matching assets');
});
```

##### `filterAssets({String? type, String? status})`
Filters assets by type and/or status.

**Parameters:**
- `type`: Asset type (optional)
- `status`: Asset status (optional)

**Returns:** `Stream<List<InfrastructureAsset>>`

**Example:**
```dart
firebaseService.filterAssets(
  type: 'Road',
  status: 'Good',
).listen((assets) {
  print('Filtered assets: ${assets.length}');
});
```

---

## 📊 Data Models

### InfrastructureAsset Model

**Location**: `lib/models/infrastructure_model.dart`

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String?` | Firestore document ID |
| `name` | `String` | Asset name |
| `type` | `String` | Asset type |
| `location` | `String` | Asset location |
| `status` | `String` | Current status |
| `description` | `String` | Detailed description |
| `lastInspectionDate` | `DateTime` | Last inspection date |
| `createdAt` | `DateTime` | Creation timestamp |

#### Constants

##### Asset Types
```dart
static const List<String> types = [
  'Road',
  'Bridge',
  'Street Light',
  'Water Pipeline',
  'Drainage',
  'Park',
  'Bus Stop',
  'Public Toilet',
  'Government Building',
];
```

##### Asset Statuses
```dart
static const List<String> statuses = [
  'Good',
  'Maintenance Required',
  'Damaged',
  'Critical',
];
```

#### Methods

##### `fromFirestore(DocumentSnapshot doc)`
Creates an InfrastructureAsset from Firestore document.

**Example:**
```dart
final asset = InfrastructureAsset.fromFirestore(docSnapshot);
```

##### `toMap()`
Converts asset to Map for Firestore.

**Example:**
```dart
final assetMap = asset.toMap();
await firestore.collection('assets').add(assetMap);
```

---

## 🎨 Widgets

### DashboardCard

**Location**: `lib/widgets/dashboard_cards.dart`

Displays a statistic card with icon and value.

**Properties:**
- `title`: Card title
- `value`: Display value
- `icon`: Icon to show
- `color`: Theme color

**Example:**
```dart
DashboardCard(
  title: 'Total Assets',
  value: '150',
  icon: Icons.account_tree,
  color: Colors.blue,
)
```

### AppSidebar

**Location**: `lib/widgets/sidebar.dart`

Navigation sidebar with collapsible functionality.

**Properties:**
- `isCollapsed`: Whether sidebar is collapsed
- `onToggle`: Callback for toggle action

**Example:**
```dart
AppSidebar(
  isCollapsed: false,
  onToggle: () => setState(() => isCollapsed = !isCollapsed),
)
```

### Charts

**Location**: `lib/widgets/charts.dart`

#### AssetPieChart
Displays asset distribution by type.

**Properties:**
- `assets`: List of assets

#### AssetBarChart
Shows assets by status.

**Properties:**
- `assets`: List of assets

#### AssetLineChart
Displays asset growth over time.

**Properties:**
- `assets`: List of assets

---

## 🛣️ Routing

### Routes Configuration

**Location**: `lib/main.dart`

| Route | Page | Parameters |
|-------|------|------------|
| `/` | LoginPage | None |
| `/dashboard` | DashboardPage | None |
| `/infrastructure` | InfrastructureListPage | None |
| `/add-asset` | AddInfrastructurePage | None |
| `/edit-asset/:id` | EditInfrastructurePage | `id` |
| `/asset-detail/:id` | AssetDetailPage | `id` |
| `/analytics` | AnalyticsPage | None |

### Navigation Examples

```dart
// Navigate to dashboard
context.go('/dashboard');

// Navigate to edit page with ID
context.go('/edit-asset/abc123');

// Navigate back
context.pop();
```

---

## 🔒 Security Rules

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Infrastructure assets collection
    match /infrastructure_assets/{assetId} {
      // Allow read/write only for authenticated users
      allow read, write: if request.auth != null;
      
      // Validate data structure
      allow create: if request.auth != null
        && request.resource.data.keys().hasAll([
          'name', 'type', 'location', 'status',
          'description', 'lastInspectionDate', 'createdAt'
        ]);
      
      allow update: if request.auth != null
        && request.resource.data.keys().hasAll([
          'name', 'type', 'location', 'status',
          'description', 'lastInspectionDate', 'createdAt'
        ]);
    }
  }
}
```

---

## 🎯 State Management

This application uses **Provider** for state management.

### Current Providers

1. **AuthService**: Manages authentication state

**Usage:**
```dart
final authService = Provider.of<AuthService>(context);
final user = authService.currentUser;
```

---

## 🧪 Testing Guide

### Unit Testing Services

```dart
test('FirebaseService adds asset', () async {
  final service = FirebaseService();
  final asset = InfrastructureAsset(
    name: 'Test Road',
    type: 'Road',
    location: 'Test Location',
    status: 'Good',
    description: 'Test description',
    lastInspectionDate: DateTime.now(),
    createdAt: DateTime.now(),
  );
  
  await service.addAsset(asset);
  // Verify asset was added
});
```

---

## 📈 Performance Optimization

### Best Practices Implemented

1. **Stream Builders**: Real-time data updates
2. **Lazy Loading**: Load data only when needed
3. **Caching**: Provider caches authentication state
4. **Pagination**: Ready for implementation in data table
5. **Indexed Queries**: Firestore indexes for fast filtering

---

## 🔄 Data Flow

```
User Action → Widget → Service → Firebase → Stream → Widget Update
```

**Example: Adding an Asset**

1. User fills form in `AddInfrastructurePage`
2. Form validation runs
3. `FirebaseService.addAsset()` called
4. Data sent to Firestore
5. Stream updates automatically
6. UI reflects new data
7. User redirected to list page

---

## 🚀 Future Enhancements

Potential features to add:

- [ ] User roles and permissions
- [ ] Asset image uploads
- [ ] Export data to CSV/PDF
- [ ] Email notifications
- [ ] Mobile app version
- [ ] Offline support
- [ ] Advanced analytics
- [ ] Maintenance scheduling
- [ ] QR code generation
- [ ] Map integration

---

**Documentation Version**: 1.0.0  
**Last Updated**: 2024
