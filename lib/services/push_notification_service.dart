import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handler(RemoteMessage message) async {
    
    // Manejar el mensaje recibido en background
    print('Mensaje recibido en background: ${message.notification?.title}');
    // Aquí puedes manejar la notificación como desees
  }
  Future<void> initialize() async {
    // Solicitar permisos para notificaciones (iOS)
    await _firebaseMessaging.requestPermission();

    // Obtener el token del dispositivo
    String? token = await _firebaseMessaging.getToken();
    print('Firebase Messaging Token: $token');

    //Implementar el token
    FirebaseMessaging.onBackgroundMessage(handler);

    // Configurar handlers para mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en foreground: ${message.notification?.title}');
      // Aquí puedes manejar la notificación como desees
    });

    // Configurar handlers para mensajes cuando la app está en background o terminada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta desde background: ${message.notification?.title}');
      // Aquí puedes navegar o realizar acciones específicas
    });
  }
}