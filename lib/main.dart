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
import 'package:uniplanner/providers/Finanzas_Provider.dart';
import 'package:uniplanner/providers/GoogleAuthProvider.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:uniplanner/services/push_notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Inicialización de notificaciones
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Pide permisos antes de iniciar la app
  await requestPermissions();

  // Configuración de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de Firebase Messaging (Push Notifications)
  await PushNotificationService().initialize();

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
        ChangeNotifierProvider(create: (_) => FinanzasProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => SQLiteHelper()),
        ChangeNotifierProvider(create: (_) => GoogleAuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'UniPlanner',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            routes: AppRoutes.routes,
            initialRoute: '/', // AuthWrapper está en las rutas
          );
        },
      ),
    );
  }
}

Future<void> requestPermissions() async {
  // NOTIFICACIONES (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // ALARMAS EXACTAS (Android 12+)
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}
