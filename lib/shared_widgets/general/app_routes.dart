import 'package:firebase_auth/firebase_auth.dart';
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
import '../../features/notas/EditarCurso.dart';
import '../../features/notas/RegistrarNotas.dart';
import '../../features/recordatorios/recordatorios_screen.dart';
import '../../features/recordatorios/edit_task_screen.dart';
import '../../features/recordatorios/add_task_reminder_screen.dart';
// Importa las nuevas pantallas que crearemos
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../wrapper/auth_wrapper.dart';

class AppRoutes {
  // Rutas principales
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String splash = '/splash';
  static const String configuracion = '/configuracion';
  static const String root = '/';

  // Nuevas rutas de autenticación
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String profileSetup = '/profile-setup';

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
  static const String editarCurso = '/editar_curso';
  static const String registrarNotas = '/registrar_notas';

  // Recordatorios
  static const String recordatorios = '/recordatorios';
  static const String editReminderEvent = '/editReminderEvent';
  static const String editReminderTask = '/editReminderTask';
  static const String addTaskReminderScreen = '/addReminderTask';

  static Map<String, WidgetBuilder> get routes => {
        root: (context) => const AuthWrapper(),
        login: (context) => const LoginScreen(),
        register: (context) => const CrearCuenta(),
        home: (context) => const HomeScreen(),
        configuracion: (context) => const ConfiguracionScreen(),

        // Nuevas rutas de autenticación
        forgotPassword: (context) => const ForgotPasswordScreen(),
        emailVerification: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as User?;
          if (args == null) {
            Navigator.pop(context);
            return const Center(child: Text('Error: Usuario requerido'));
          }
          return EmailVerificationScreen(user: args);
        },
        profileSetup: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as User?;
          return ProfileSetupScreen(user: args);
        },

        // Calendario
        calendario: (context) => const Calendario(),
        addEvent: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is! String) {
            Navigator.pop(context);
            return const Center(child: Text('Error: UserID requerido'));
          }

          return AggEvento(userId: args);
        },
        editEvent: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          if (args == null || args['event'] == null || args['userId'] == null) {
            Navigator.pop(context);
            return const Center(
                child: Text('Error: Datos del evento requeridos'));
          }

          return EditEvento(
            event: args['event'],
            userId: args['userId'],
          );
        },
        taskInput: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is! String) {
            Navigator.pop(context);
            return const Center(child: Text('Error: UserID requerido'));
          }

          return TaskInputScreen(userId: args);
        },
        editTask: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          if (args == null || args['task'] == null || args['userId'] == null) {
            Navigator.pop(context);
            return const Center(
                child: Text('Error: Datos de la tarea requeridos'));
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
        editarCurso: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null ||
              args['courseId'] == null ||
              args['courseName'] == null) {
            Navigator.pop(context);
            return const Center(
                child: Text('Error: Datos del curso requeridos'));
          }
          return EditarCurso(
            courseId: (args['courseId'] as String).toString(),
            courseName: args['courseName'] as String,
            courseLabel: args['courseLabel'] as String? ?? '',
          );
        },
        registrarNotas: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null ||
              args['courseId'] == null ||
              args['courseName'] == null) {
            Navigator.pop(context);
            return const Center(
                child: Text('Error: Datos del curso requeridos'));
          }
          return RegistrarNotas(
            courseId: (args['courseId'] as String).toString(),
            courseName: args['courseName'] as String,
          );
        },

        // Recordatorios
        recordatorios: (context) => const RecordatoriosScreen(),
        editReminderTask: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          if (args == null ||
              args['task'] == null ||
              args['userId'] == null ||
              args['availableLists'] == null) {
            Navigator.pop(context);
            return const Center(
                child: Text('Error: Datos de la tarea requeridos'));
          }

          return EditTaskReminderScreen(
            task: args['task'],
            userId: args['userId'],
            availableLists:
                args['availableLists'], // Pasar las listas disponibles
          );
        },
        addTaskReminderScreen: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          if (args == null ||
              args['userId'] == null ||
              args['defaultList'] == null) {
            Navigator.pop(context);
            return const Center(
                child: Text('Error: Datos requeridos no proporcionados'));
          }

          return AddTaskReminderScreen(
            userId: args['userId'],
            defaultList: args['defaultList'],
            availableLists: args['availableLists'],
          );
        },
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
