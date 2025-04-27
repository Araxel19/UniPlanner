import 'package:flutter/material.dart';
import 'app_routes.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                blurRadius: 4.0,
                offset: const Offset(0, -2),
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
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, BuildContext context, VoidCallback onPressed) {
    final theme = Theme.of(context);

    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 24.0, color: theme.iconTheme.color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
        ),
      ],
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.calendario);
  }

  void _navigateToFinance(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.finanzas);
  }

  void _navigateToNotas(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.calculadora);
  }

  void _navigateToTasks(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.recordatorios);
  }


}
