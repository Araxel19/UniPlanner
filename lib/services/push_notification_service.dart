import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

// Instancia global para notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Handler de background debe ser top-level
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Mostrar notificación local en background
  if (message.notification != null) {
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title ?? 'Notificación',
      message.notification!.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_channel',
          'Notificaciones Push',
          channelDescription: 'Notificaciones recibidas por FCM',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  print('Mensaje recibido en background: ${message.notification?.title}');
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handler(RemoteMessage message) async {
    // Mostrar notificación local en background
    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title ?? 'Notificación',
        message.notification!.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'push_channel',
            'Notificaciones Push',
            channelDescription: 'Notificaciones recibidas por FCM',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
    print('Mensaje recibido en background: ${message.notification?.title}');
  }

  Future<void> initialize() async {
    // Inicializa el plugin de notificaciones locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print('Firebase Messaging Token: $token');

    // Registrar el handler de background correctamente
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Mostrar notificación local en foreground
      if (message.notification != null) {
        await flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title ?? 'Notificación',
          message.notification!.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'push_channel',
              'Notificaciones Push',
              channelDescription: 'Notificaciones recibidas por FCM',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
      print('Mensaje recibido en foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta desde background: ${message.notification?.title}');
      // Aquí puedes navegar o realizar acciones específicas
    });
  }

  /// Programa una notificación para la hora de inicio del evento.
  /// [startTime] es la hora de inicio del evento.
  /// [title] y [body] son los datos de la notificación.
  Future<void> scheduleNotification(DateTime startTime, {required String title, required String body}) async {
    final now = DateTime.now();

    if (!startTime.isAfter(now)) {
      print('Error programando notificación: La fecha debe estar en el futuro.');
      return;
    }

    final duration = startTime.difference(now);

    Timer(duration, () async {
      // Mostrar notificación local cuando llegue la hora
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'push_channel',
            'Notificaciones Push',
            channelDescription: 'Notificaciones recibidas por FCM',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      print('Notificación programada: $title - $body');
    });
  }
}