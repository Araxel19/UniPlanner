import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/task_item.dart';
import '../widgets/balance_card.dart';
import '../widgets/bottom_navigation.dart';
import 'configuracion.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) {
    // Lógica para limpiar datos de sesión
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with welcome message and user icon
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // En el header, corrige el Row:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BIENVENIDO SAMUEL 😊',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.account_circle, size: 41),
                        onSelected: (value) {
                          if (value == 'config') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ConfiguracionScreen(),
                              ),
                            );
                          } else if (value == 'logout') {
                            _logout(context);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'config',
                              child: Row(
                                children: [
                                  Icon(Icons.settings, color: Colors.blue),
                                  SizedBox(width: 12),
                                  Text('Configuración'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.exit_to_app, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Cerrar sesión'),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Motivational quote
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        margin: const EdgeInsets.only(bottom: 32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(),
                              blurRadius: 4.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '"Cada paso que das te acerca a tu meta, sigue avanzando." 🚀...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                      ),

                      // Today's tasks section
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 600),
                        padding: const EdgeInsets.all(24.0),
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBDD8F8),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Hoy 📅',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16.0),
                            const TaskItem(text: '✅ Taller PNL'),
                            const SizedBox(height: 12.0),
                            const TaskItem(text: '✅ Trabajo atena'),
                            const SizedBox(height: 12.0),
                            const TaskItem(text: '✅ Ejercicio redes'),
                          ],
                        ),
                      ),

                      // Balance section
                      const BalanceCard(
                        balance: '300.000',
                        expenses: [
                          {'name': 'Pasajes', 'amount': '10.000'},
                          {'name': 'Libro Inglés', 'amount': '80.000'},
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom navigation
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
