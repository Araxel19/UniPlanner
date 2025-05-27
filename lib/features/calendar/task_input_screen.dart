import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';

class TaskInputScreen extends StatefulWidget {
  final String? userId;
  final String? defaultList;

  const TaskInputScreen({Key? key, this.userId, this.defaultList})
      : super(key: key);

  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('Debes iniciar sesión');
        return;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
        'title': _titleController.text,
        'dueDate': formattedDate,
        'dueTime': formattedTime,
        'description': _descriptionController.text,
        'isCompleted': false,
        'listName': widget.defaultList ?? 'Ideas',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await flutterLocalNotificationsPlugin.show(
        1111,
        'Tarea agregada',
        '¡La tarea se agregó correctamente!',
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
        title: const Text('Nueva Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveTask,
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
                  labelText: 'Título de la tarea',
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
                        title: const Text('Fecha de vencimiento'),
                        subtitle: Text(
                          _selectedDate == null
                              ? 'Seleccionar fecha'
                              : DateFormat('EEEE, d MMMM y').format(_selectedDate!),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const Divider(),

                      // Hora
                      ListTile(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
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
                          if (time != null) setState(() => _selectedTime = time);
                        },
                        leading: Icon(Icons.access_time, color: primaryColor),
                        title: const Text('Hora de vencimiento'),
                        subtitle: Text(
                          _selectedTime == null
                              ? 'Seleccionar hora'
                              : _selectedTime!.format(context),
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