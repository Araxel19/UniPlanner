import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AggEvento extends StatefulWidget {
  final String userId;

  const AggEvento({Key? key, required this.userId}) : super(key: key);
    
  @override
  State<AggEvento> createState() => _AggEventoState();
}

class _AggEventoState extends State<AggEvento> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _startTime == null) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('Debes iniciar sesión');
        return;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final startTimeStr = _formatTime(_startTime!);
      final endTimeStr = _endTime != null ? _formatTime(_endTime!) : startTimeStr;

      // Guarda el evento y obtén el docRef para el ID
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .add({
        'title': _titleController.text,
        'date': formattedDate,
        'startTime': startTimeStr,
        'endTime': endTimeStr,
        'description': _descriptionController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --- PROGRAMA LA NOTIFICACIÓN ---
      final DateTime scheduledDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      // Convierte a TZDateTime
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Solo programa la notificación si la fecha es futura
      if (tzScheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        await scheduleNotification(
          id: docRef.id.hashCode,
          title: '¡Tienes un evento!',
          body: _titleController.text,
          scheduledDate: tzScheduledDate,
          context: context,
        );
      }

       await flutterLocalNotificationsPlugin.show(
              1111,
              'Evento agregado',
              '¡El evento se agregó correctamente!',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'tareas_channel',
                  'Tareas y eventos',
                  channelDescription: 'Notificaciones de tareas y eventos',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al guardar: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardTheme.color ?? Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveEvent,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título del evento',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(color: onSurfaceColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Fecha y hora
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Fecha
                      ListTile(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: primaryColor,
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) setState(() => _selectedDate = date);
                        },
                        leading: Icon(Icons.calendar_today, color: primaryColor),
                        title: const Text('Fecha'),
                        subtitle: Text(
                          _selectedDate == null
                              ? 'Seleccionar fecha'
                              : DateFormat('EEEE, d MMMM y').format(_selectedDate!),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const Divider(),

                      // Hora inicio
                      ListTile(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _startTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: primaryColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) setState(() => _startTime = time);
                        },
                        leading: Icon(Icons.access_time, color: primaryColor),
                        title: const Text('Hora de inicio'),
                        subtitle: Text(
                          _startTime == null
                              ? 'Seleccionar hora'
                              : _startTime!.format(context),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const Divider(),

                      // Hora fin
                      ListTile(
                        onTap: () async {
                          if (_startTime == null) {
                            _showErrorDialog('Primero selecciona una hora de inicio');
                            return;
                          }
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _endTime ?? _startTime!,
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: primaryColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
                            final endMinutes = time.hour * 60 + time.minute;
                            if (endMinutes < startMinutes) {
                              _showErrorDialog('La hora de fin debe ser posterior a la de inicio');
                            } else {
                              setState(() => _endTime = time);
                            }
                          }
                        },
                        leading: Icon(Icons.access_time_outlined, color: primaryColor),
                        title: const Text('Hora de fin'),
                        subtitle: Text(
                          _endTime == null
                              ? 'Seleccionar hora'
                              : _endTime!.format(context),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(color: onSurfaceColor),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}