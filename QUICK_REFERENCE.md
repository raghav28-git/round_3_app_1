# ⚡ Quick Reference Guide

## 🚀 Common Commands

### Development
```bash
# Run in Chrome
flutter run -d chrome

# Run with hot reload
flutter run -d chrome --hot

# Clean build
flutter clean && flutter pub get && flutter run -d chrome
```

### Build & Deploy
```bash
# Build for production
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting

# Build and deploy
flutter build web --release && firebase deploy --only hosting
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

---

## 🔥 Firebase Quick Setup

### 1. Create Project
```bash
# Login to Firebase
firebase login

# Initialize project
firebase init
```

### 2. Enable Services
- ✅ Authentication → Email/Password
- ✅ Firestore Database → Test mode
- ✅ Hosting → Enable

### 3. Security Rules
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /infrastructure_assets/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📝 Code Snippets

### Add New Asset
```dart
final asset = InfrastructureAsset(
  name: 'Main Street',
  type: 'Road',
  location: 'Downtown',
  status: 'Good',
  description: 'Primary road',
  lastInspectionDate: DateTime.now(),
  createdAt: DateTime.now(),
);
await FirebaseService().addAsset(asset);
```

### Search Assets
```dart
FirebaseService().searchAssets('bridge').listen((results) {
  print('Found: ${results.length}');
});
```

### Filter Assets
```dart
FirebaseService().filterAssets(
  type: 'Road',
  status: 'Good',
).listen((assets) {
  // Handle filtered results
});
```

### Navigate
```dart
// Go to page
context.go('/dashboard');

// Go with parameter
context.go('/edit-asset/$assetId');

// Go back
context.pop();
```

---

## 🎨 UI Customization

### Change Primary Color
```dart
// In main.dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.purple.shade900, // Your color
  brightness: Brightness.light,
),
```

### Modify Card Style
```dart
CardTheme(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
)
```

### Custom Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Button'),
)
```

---

## 🐛 Troubleshooting

### Firebase Not Initialized
```dart
// Ensure this is in main()
await Firebase.initializeApp(
  options: FirebaseOptions(
    // Your config here
  ),
);
```

### Authentication Error
```bash
# Check Firebase Console
# Authentication → Sign-in method → Email/Password → Enabled
```

### Firestore Permission Denied
```javascript
// Update Firestore rules
allow read, write: if request.auth != null;
```

### Build Errors
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Hot Reload Not Working
```bash
# Press 'r' in terminal
# Or restart: Press 'R'
```

---

## 📊 Data Structure

### Infrastructure Asset
```json
{
  "name": "Main Street Road",
  "type": "Road",
  "location": "Ward 12",
  "status": "Good",
  "description": "Primary connecting road",
  "lastInspectionDate": "2024-01-15T10:30:00Z",
  "createdAt": "2024-01-01T08:00:00Z"
}
```

### Asset Types
```dart
['Road', 'Bridge', 'Street Light', 'Water Pipeline', 
 'Drainage', 'Park', 'Bus Stop', 'Public Toilet', 
 'Government Building']
```

### Status Options
```dart
['Good', 'Maintenance Required', 'Damaged', 'Critical']
```

---

## 🔐 Authentication

### Login
```dart
await AuthService().signIn(
  'admin@smartcity.com',
  'password123',
);
```

### Logout
```dart
await AuthService().signOut();
```

### Check Auth State
```dart
final user = AuthService().currentUser;
if (user != null) {
  print('Logged in: ${user.email}');
}
```

---

## 📱 Responsive Breakpoints

```dart
// Mobile
if (MediaQuery.of(context).size.width < 600) { }

// Tablet
if (MediaQuery.of(context).size.width < 900) { }

// Desktop
if (MediaQuery.of(context).size.width >= 900) { }
```

---

## 🎯 Testing Checklist

- [ ] Login with valid credentials
- [ ] Login with invalid credentials (should fail)
- [ ] Add new asset
- [ ] Edit existing asset
- [ ] Delete asset (with confirmation)
- [ ] Search functionality
- [ ] Filter by type
- [ ] Filter by status
- [ ] View asset details
- [ ] Dashboard statistics update
- [ ] Charts display correctly
- [ ] Logout functionality
- [ ] Responsive on different screen sizes

---

## 📦 Package Versions

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  fl_chart: ^0.69.0
  data_table_2: ^2.5.15
  go_router: ^14.6.2
  provider: ^6.1.2
  intl: ^0.19.0
```

---

## 🌐 URLs

### Development
```
http://localhost:PORT
```

### Production
```
https://your-project-id.web.app
https://your-project-id.firebaseapp.com
```

---

## 💡 Pro Tips

1. **Use Hot Reload**: Press `r` for quick updates
2. **Stream Builders**: Automatic UI updates with Firestore
3. **Provider**: Access services anywhere with `Provider.of<T>(context)`
4. **Error Handling**: Always wrap Firebase calls in try-catch
5. **Loading States**: Show progress indicators during async operations
6. **Validation**: Validate forms before submitting
7. **Confirmation Dialogs**: Ask before destructive operations
8. **Toast Messages**: Provide feedback for user actions

---

## 🔗 Useful Links

- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlChart Examples](https://github.com/imaNNeo/fl_chart)
- [Material Design](https://m3.material.io/)
- [Go Router Docs](https://pub.dev/packages/go_router)

---

## 📞 Quick Help

### Error: "Firebase not initialized"
**Solution**: Check `main.dart` Firebase configuration

### Error: "Permission denied"
**Solution**: Update Firestore security rules

### Error: "User not found"
**Solution**: Create user in Firebase Console → Authentication

### Charts not showing
**Solution**: Add sample data first

### Build fails
**Solution**: Run `flutter clean && flutter pub get`

---

**Last Updated**: 2024  
**Version**: 1.0.0

---

<div align="center">

**Need more help?** Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

</div>
