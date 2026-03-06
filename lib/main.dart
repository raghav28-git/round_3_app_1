import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/infrastructure_list_page.dart';
import 'pages/add_infrastructure_page.dart';
import 'pages/edit_infrastructure_page.dart';
import 'pages/asset_detail_page.dart';
import 'pages/analytics_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDI0NvqiPg_zC6LrnD6JVQaFrDZjSbdGFY",
      authDomain: "smart-city-portal-77518.firebaseapp.com",
      projectId: "smart-city-portal-77518",
      storageBucket: "smart-city-portal-77518.firebasestorage.app",
      messagingSenderId: "62822737525",
      appId: "1:62822737525:web:1e36dbbe1bc48f82bffa3c",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'Smart City Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade900,
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/infrastructure',
      builder: (context, state) => const InfrastructureListPage(),
    ),
    GoRoute(
      path: '/add-asset',
      builder: (context, state) => const AddInfrastructurePage(),
    ),
    GoRoute(
      path: '/edit-asset/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditInfrastructurePage(assetId: id);
      },
    ),
    GoRoute(
      path: '/asset-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AssetDetailPage(assetId: id);
      },
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsPage(),
    ),
  ],
);
