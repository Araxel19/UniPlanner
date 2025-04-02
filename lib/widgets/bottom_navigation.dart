import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/calendario/calendario.dart';
import '../screens/finanzas/finanzas.dart';
import '../screens/notas/Calculadora.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(),
                blurRadius: 4.0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Inicio", context, () => _navigateToHome(context)),
              _buildNavItem(Icons.calendar_today, "Calendario", context, () => _navigateToCalendar(context)),
              _buildNavItem(Icons.assignment, "Recordatorios", context, () => _navigateToTasks(context)),
              _buildNavItem(Icons.attach_money, "Finanzas", context, () => _navigateToFinance(context)),
              _buildNavItem(Icons.calculate, "Notas", context, () => _navigateToNotas(context)),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 5.0,
          width: 134.0,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, BuildContext context, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 24.0),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        )
      ],
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
  void _navigateToCalendar(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Calendario()),
    );
  }

  void _navigateToFinance(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FinanzasScreen()),
    );
  }

  void _navigateToNotas(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Calculadora()),
    );
  }
  // Funciones placeholder para otras pantallas
  void _navigateToTasks(BuildContext context) => _showPlaceholder(context, "Tareas");

  void _showPlaceholder(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pantalla de $screenName en desarrollo 🚧")),
    );
  }
}