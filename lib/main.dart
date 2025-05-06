import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared_widgets/general/app_routes.dart';
import 'providers/theme_provider.dart';
import 'package:uniplanner/providers/user_provider.dart';
import 'package:uniplanner/providers/auth_provider.dart';
import 'core/db/sqlite_helper.dart';
import 'core/db/auth_service.dart';
import 'core/db/firestore_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainWrapper());
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final provider = ThemeProvider();
            provider.initialize(); // Inicializa el tema
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => SQLiteHelper()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'UniPlanner',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}