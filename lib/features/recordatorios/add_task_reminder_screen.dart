import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class AddTaskReminderScreen extends StatefulWidget {
  final String userId;
  final String defaultList;
  final List<String> availableLists;

  const AddTaskReminderScreen({
    Key? key,
    required this.userId,
    required this.defaultList,
    required this.availableLists,
  }) : super(key: key);

  @override
  State<AddTaskReminderScreen> createState() => _AddTaskReminderScreenState();
}

class _AddTaskReminderScreenState extends State<AddTaskReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String _selectedList;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.availableLists.contains(widget.defaultList)
        ? widget.defaultList
        : widget.availableLists.isNotEmpty
            ? widget.availableLists.first
            : 'Ideas';
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('tasks')
          .add({
        'title': _titleController.text,
        'dueDate': formattedDate,
        'dueTime': formattedTime,
        'description': _descriptionController.text,
        'listName': _selectedList,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Notificación programada
      final DateTime scheduledDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      if (tzScheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        await scheduleNotification(
          context: context,
          id: docRef.id.hashCode, // <-- ¡Así!
          title: 'Recordatorio: ${_titleController.text}',
          body: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Tienes una tarea pendiente',
          scheduledDate: tzScheduledDate,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tarea con Recordatorio'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                        onTap: _selectDate,
                        leading:
                            Icon(Icons.calendar_today, color: primaryColor),
                        title: const Text('Fecha de vencimiento'),
                        subtitle: Text(
                          DateFormat('EEEE, d MMMM y').format(_selectedDate),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const Divider(),

                      // Hora
                      ListTile(
                        onTap: _selectTime,
                        leading: Icon(Icons.access_time, color: primaryColor),
                        title: const Text('Hora de recordatorio'),
                        subtitle: Text(
                          _selectedTime.format(context),
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
                maxLines: 4,
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

              // Lista de tareas
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedList,
                    items: widget.availableLists
                        .map((list) => DropdownMenuItem(
                              value: list,
                              child: Text(list),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedList = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Lista de tareas',
                      border: InputBorder.none,
                    ),
                    dropdownColor: theme.cardColor,
                    style: TextStyle(color: onSurfaceColor),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
