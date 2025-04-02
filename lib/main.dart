import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/crear_cuenta.dart';
import 'screens/calendario/calendario.dart';
import 'screens/finanzas/finanzas.dart';
import 'screens/notas/calculadora.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniPlanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 12,
          ),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/crear_cuenta': (context) => const CrearCuenta(),
        '/calendario': (context) => const Calendario(),
        '/finanzas': (context) => const FinanzasScreen(),
        '/notas': (context) => const Calculadora(),
      },
    );
  }
}