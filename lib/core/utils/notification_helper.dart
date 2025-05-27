import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification({
  required BuildContext context,
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tareas_channel',
          'Tareas y eventos',
          channelDescription: 'Notificaciones de tareas y eventos',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  } on PlatformException catch (e) {
    if (e.code == 'exact_alarms_not_permitted') {
      await showPermissionDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  } catch (e) {
    debugPrint("Otro error: $e");
  }
}

Future<void> showPermissionDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permiso necesario'),
      content: const Text(
        'Para activar notificaciones exactas, es necesario habilitar el permiso en la configuración.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Abrir ajustes'),
          onPressed: () {
            openExactAlarmSettings();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

Future<void> openExactAlarmSettings() async {
  const intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  await intent.launch();
}
