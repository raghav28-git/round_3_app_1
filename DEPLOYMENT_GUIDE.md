# 🚀 DEPLOYMENT GUIDE - Smart City Portal

## Quick Start (5 Minutes)

### Step 1: Install Dependencies
```bash
cd round_3_app_1
flutter pub get
```

### Step 2: Firebase Project Setup

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Click "Add project"
   - Enter project name: "smart-city-portal"
   - Disable Google Analytics (optional)
   - Click "Create project"

2. **Enable Authentication**
   - In Firebase Console, go to **Authentication**
   - Click "Get started"
   - Select "Email/Password"
   - Enable it and click "Save"

3. **Enable Firestore Database**
   - Go to **Firestore Database**
   - Click "Create database"
   - Start in **Test mode** (for development)
   - Choose location (closest to you)
   - Click "Enable"

4. **Add Web App**
   - Go to Project Settings (gear icon)
   - Scroll to "Your apps"
   - Click Web icon (</>)
   - Register app name: "Smart City Web"
   - Copy the Firebase configuration

### Step 3: Configure Firebase in Your App

Open `lib/main.dart` and replace the Firebase configuration (around line 12):

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abcdef1234567890",
  ),
);
```

### Step 4: Update Firestore Security Rules

In Firebase Console → Firestore Database → Rules, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /infrastructure_assets/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Click "Publish"

### Step 5: Create Admin User

In Firebase Console → Authentication → Users:
- Click "Add user"
- Email: `admin@smartcity.com`
- Password: `Admin@123456`
- Click "Add user"

### Step 6: Run the Application

```bash
flutter run -d chrome
```

**Login with:**
- Email: admin@smartcity.com
- Password: Admin@123456

---

## 📱 Application Features

### 1. Dashboard
- View total infrastructure assets
- See assets by condition (Good, Maintenance, Critical)
- Interactive charts:
  - Pie chart: Asset distribution by type
  - Bar chart: Assets by status
  - Line chart: Asset growth over time

### 2. Infrastructure Management
- **View All Assets**: Searchable, filterable table
- **Add New Asset**: Form with validation
- **Edit Asset**: Update existing records
- **Delete Asset**: Remove with confirmation
- **View Details**: Full asset information

### 3. Analytics
- Comprehensive data visualization
- Asset distribution insights
- Location-based statistics
- Type and status breakdowns

### 4. Search & Filter
- Search by name or location
- Filter by asset type
- Filter by status
- Real-time results

---

## 🏗️ Asset Types Available

1. Road
2. Bridge
3. Street Light
4. Water Pipeline
5. Drainage
6. Park
7. Bus Stop
8. Public Toilet
9. Government Building

## 📊 Status Options

- **Good** (Green) - Asset in good condition
- **Maintenance Required** (Orange) - Needs attention
- **Damaged** (Light Red) - Requires repair
- **Critical** (Red) - Urgent action needed

---

## 🌐 Deploy to Firebase Hosting

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Initialize Firebase Hosting

```bash
firebase init hosting
```

Select:
- Use existing project
- Public directory: `build/web`
- Configure as single-page app: Yes
- Set up automatic builds: No

### Step 4: Build Flutter Web

```bash
flutter build web --release
```

### Step 5: Deploy

```bash
firebase deploy --only hosting
```

Your app will be live at: `https://your-project-id.web.app`

---

## 🧪 Testing the Application

### Add Sample Data

1. Login to the application
2. Go to "Add Asset" from sidebar
3. Fill in the form:
   - **Name**: Main Street Road
   - **Type**: Road
   - **Location**: Ward 12, Downtown
   - **Status**: Good
   - **Last Inspection**: Select a date
   - **Description**: Primary connecting road in downtown area
4. Click "Save Asset"

Repeat to add more assets with different types and statuses.

### Test Features

✅ **Dashboard**: Check if statistics update
✅ **Search**: Try searching for asset names
✅ **Filter**: Filter by type and status
✅ **Edit**: Click edit icon and modify an asset
✅ **View**: Click view icon to see details
✅ **Delete**: Click delete icon (with confirmation)
✅ **Analytics**: View charts and insights

---

## 🎨 UI Customization

### Change Primary Color

In `lib/main.dart`, modify the theme:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.purple.shade900, // Change this
  brightness: Brightness.light,
),
```

### Modify Sidebar Colors

In `lib/widgets/sidebar.dart`, change:

```dart
color: Colors.purple.shade900, // Line 22
```

---

## 🔧 Troubleshooting

### Issue: Firebase not initialized
**Solution**: Make sure you've added Firebase configuration in `main.dart`

### Issue: Authentication failed
**Solution**: 
1. Check if Email/Password is enabled in Firebase Console
2. Verify user exists in Authentication → Users

### Issue: Can't read/write to Firestore
**Solution**: Update Firestore security rules as shown in Step 4

### Issue: Charts not showing
**Solution**: Add some sample data first

### Issue: Build errors
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📦 Package Versions

All packages are compatible and tested:
- firebase_core: ^3.8.1
- firebase_auth: ^5.3.3
- cloud_firestore: ^5.5.2
- fl_chart: ^0.69.0
- go_router: ^14.6.2
- provider: ^6.1.2
- intl: ^0.19.0

---

## 🎯 Production Checklist

Before deploying to production:

- [ ] Update Firebase security rules for production
- [ ] Change default admin password
- [ ] Enable Firebase App Check
- [ ] Set up proper authentication flow
- [ ] Add error logging (Firebase Crashlytics)
- [ ] Enable HTTPS only
- [ ] Add loading states for all operations
- [ ] Test on multiple browsers
- [ ] Optimize images and assets
- [ ] Enable caching strategies

---

## 📞 Support & Resources

- **Flutter Docs**: https://docs.flutter.dev/
- **Firebase Docs**: https://firebase.google.com/docs
- **FlChart Examples**: https://github.com/imaNNeo/fl_chart/tree/master/example
- **Go Router Guide**: https://pub.dev/packages/go_router

---

## 🎉 Success!

Your Smart City Infrastructure Portal is now ready!

**Next Steps:**
1. Add real infrastructure data
2. Invite team members to Firebase project
3. Customize branding and colors
4. Deploy to production
5. Monitor usage in Firebase Console

---

**Built with Flutter 💙 | Powered by Firebase 🔥**
