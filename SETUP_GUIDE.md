# Smart City - Urban Infrastructure Data Portal

A production-level Flutter Web application for managing city infrastructure assets with Firebase backend.

## Features

✅ Firebase Authentication (Email/Password)
✅ Cloud Firestore Database
✅ Modern Material 3 UI Design
✅ Responsive Dashboard with Charts
✅ Infrastructure CRUD Operations
✅ Advanced Search & Filtering
✅ Real-time Data Updates
✅ Analytics & Insights
✅ Professional SaaS-style Interface

## Tech Stack

- **Frontend**: Flutter Web
- **Backend**: Firebase (Auth + Firestore)
- **Charts**: fl_chart
- **Routing**: go_router
- **State Management**: Provider

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable **Authentication** → Email/Password sign-in method
4. Enable **Cloud Firestore** database
5. Go to Project Settings → General → Your apps
6. Add a Web app and copy the Firebase configuration
7. Update `lib/main.dart` with your Firebase credentials:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
  ),
);
```

### 3. Firestore Security Rules

Add these rules in Firebase Console → Firestore Database → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /infrastructure_assets/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Create Admin User

In Firebase Console → Authentication → Users → Add user:
- Email: admin@smartcity.com
- Password: admin123456

### 5. Run the Application

```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── models/
│   └── infrastructure_model.dart      # Data model
├── services/
│   ├── auth_service.dart              # Authentication
│   └── firebase_service.dart          # Firestore operations
├── pages/
│   ├── login_page.dart                # Login screen
│   ├── dashboard_page.dart            # Dashboard with stats
│   ├── infrastructure_list_page.dart  # Asset table
│   ├── add_infrastructure_page.dart   # Add asset form
│   ├── edit_infrastructure_page.dart  # Edit asset form
│   ├── asset_detail_page.dart         # Asset details
│   └── analytics_page.dart            # Analytics charts
├── widgets/
│   ├── sidebar.dart                   # Navigation sidebar
│   ├── dashboard_cards.dart           # Stat cards
│   └── charts.dart                    # Chart widgets
└── main.dart                          # App entry point
```

## Features Overview

### 1. Authentication
- Email/password login
- Protected routes
- Auto-redirect after login
- Logout functionality

### 2. Dashboard
- Total assets count
- Status-based statistics
- Pie chart (asset distribution)
- Bar chart (status overview)
- Line chart (growth timeline)

### 3. Infrastructure Management
- Create new assets
- Edit existing assets
- Delete assets
- View detailed information
- Search by name/location
- Filter by type and status
- Real-time updates

### 4. Analytics
- Visual insights
- Asset distribution charts
- Location-based statistics
- Type and status breakdowns

### 5. Asset Fields
- Name
- Type (Road, Bridge, Street Light, etc.)
- Location
- Status (Good, Maintenance Required, Damaged, Critical)
- Description
- Last Inspection Date
- Created At

## UI Design

- **Color Scheme**: Deep Blue primary, Cyan accents
- **Cards**: Rounded corners with soft shadows
- **Animations**: Smooth transitions and hover effects
- **Responsive**: Works on desktop, tablet, and large screens
- **Modern**: SaaS-style dashboard (Linear/Vercel inspired)

## Deployment

### Build for Production

```bash
flutter build web --release
```

### Deploy to Firebase Hosting

```bash
firebase init hosting
firebase deploy
```

## Default Login Credentials

After creating the admin user in Firebase:
- **Email**: admin@smartcity.com
- **Password**: admin123456

## Support

For issues or questions, refer to:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlChart Documentation](https://github.com/imaNNeo/fl_chart)

---

**Built with ❤️ using Flutter & Firebase**
