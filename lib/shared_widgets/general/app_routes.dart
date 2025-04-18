import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/configuracion/configuracion.dart';
import '../../features/calendar/calendario.dart';
import '../../features/calendar/add_event_screen.dart';
import '../../features/calendar/edit_event_screen.dart';
import '../../features/calendar/task_input_screen.dart';
import '../../features/calendar/edit_task_screen.dart';
import '../../features/finanzas/finanzas_screen.dart';
import '../../features/finanzas/agregar_movimientos.dart';
import '../../features/notas/calculadora.dart';
import '../../features/notas/registrar_curso.dart';

class AppRoutes {
  // Rutas principales
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String configuracion = '/configuracion';

  // Calendario
  static const String calendario = '/calendario';
  static const String addEvent = '/add_event';
  static const String editEvent = '/edit_event';
  static const String taskInput = '/task_input';
  static const String editTask = '/edit_task';

  // Finanzas
  static const String finanzas = '/finanzas';
  static const String agregarMovimiento = '/agregar_movimiento';

  // Notas
  static const String calculadora = '/calculadora';
  static const String registrarCurso = '/registrar_curso';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const CrearCuenta(),
    home: (context) => const HomeScreen(),
    configuracion: (context) => const ConfiguracionScreen(),

    // Calendario
    calendario: (context) => const Calendario(),
    addEvent: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args is! int) {
        Navigator.pop(context);
        return const Center(child: Text('Error: UserID requerido'));
      }
      
      return AggEvento(userId: args);
    },
    editEvent: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args == null || args['event'] == null || args['userId'] == null) {
        Navigator.pop(context);
        return const Center(child: Text('Error: Datos del evento requeridos'));
      }
      
      return EditEvento(
        event: args['event'],
        userId: args['userId'],
      );
    },
    taskInput: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args is! int) {
        Navigator.pop(context);
        return const Center(child: Text('Error: UserID requerido'));
      }
      
      return TaskInputScreen(userId: args);
    },
    editTask: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args == null || args['task'] == null || args['userId'] == null) {
        Navigator.pop(context);
        return const Center(child: Text('Error: Datos de la tarea requeridos'));
      }
      
      return EditTaskScreen(
        task: args['task'],
        userId: args['userId'],
      );
    },

    // Finanzas
    finanzas: (context) => const FinanzasScreen(),
    agregarMovimiento: (context) => const AgregarMovimientos(),

    // Notas
    calculadora: (context) => const Calculadora(),
    registrarCurso: (context) => const RegistrarCurso(),
  };

  // Método helper para navegar con argumentos
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }
}