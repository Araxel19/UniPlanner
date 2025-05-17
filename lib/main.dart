import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/providers/auth_provider.dart' as auth_provider;
import 'package:uniplanner/shared_widgets/general/app_routes.dart';
import 'package:uniplanner/providers/theme_provider.dart';
import 'package:uniplanner/providers/user_provider.dart';
import 'package:uniplanner/core/db/sqlite_helper.dart';
import 'package:uniplanner/core/db/auth_service.dart';
import 'package:uniplanner/core/db/firestore_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración mejorada de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UniPlannerApp());
}

class UniPlannerApp extends StatelessWidget {
  const UniPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => auth_provider.AuthProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => SQLiteHelper()),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'UniPlanner',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const AuthWrapper(),
      routes: AppRoutes.routes,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);

    if (!authProvider.initialAuthCheckComplete) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return authProvider.user != null
        ? AppRoutes.routes[AppRoutes.home]!(context)
        : AppRoutes.routes[AppRoutes.login]!(context);
  }
}
