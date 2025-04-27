import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared_widgets/general/app_routes.dart';
import '/providers/theme_provider.dart';
import '/core/db/sqlite_helper.dart'; // Asegúrate de importar SQLiteHelper

void main() => runApp(const MainWrapper());

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeTheme(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => snapshot.data as ThemeProvider),
              Provider(create: (_) => SQLiteHelper()), // Agrega SQLiteHelper aquí
            ],
            child: const MyApp(),
          );
        }
        return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
      },
    );
  }

  Future<ThemeProvider> _initializeTheme() async {
    final themeProvider = ThemeProvider();
    await themeProvider.loadTheme();
    return themeProvider;
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