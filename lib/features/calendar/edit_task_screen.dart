import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTaskScreen extends StatefulWidget {
  final dynamic task; // Puede ser Map o Task
  final String userId;

  const EditTaskScreen({Key? key, required this.task, required this.userId})
      : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late String _taskId;
  bool _isCompleted = false;
  late String _listName;

  @override
  void initState() {
    super.initState();

    // Manejar tanto Map como objeto Task
    _taskId = widget.task is Map ? widget.task['id'] : widget.task.id;
    _titleController = TextEditingController(
        text: widget.task is Map ? widget.task['title'] : widget.task.title);
    _descriptionController = TextEditingController(
        text: widget.task is Map
            ? widget.task['description'] ?? ''
            : widget.task.description ?? '');
    _isCompleted = widget.task is Map
        ? widget.task['isCompleted'] ?? false
        : widget.task.isCompleted;
    _listName = widget.task is Map
        ? widget.task['listName'] ?? 'Ideas'
        : widget.task.listName ?? 'Ideas';

    // Parsear fecha
    final dueDate =
        widget.task is Map ? widget.task['dueDate'] : widget.task.dueDate;
    _selectedDate = DateFormat('yyyy-MM-dd').parse(dueDate);

    // Parsear hora
    final dueTime = widget.task is Map
        ? widget.task['dueTime'] ?? '00:00'
        : widget.task.dueTime ?? '00:00';
    final timeParts = dueTime.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('Debes iniciar sesión');
        return;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(_taskId) // Usamos _taskId en lugar de widget.task.id
          .update({
        'title': _titleController.text,
        'dueDate': formattedDate,
        'dueTime': formattedTime,
        'description': _descriptionController.text,
        'isCompleted': _isCompleted,
        'listName': _listName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al actualizar: ${e.toString()}');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _updateTask,
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
                        title: const Text('Hora de vencimiento'),
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

              // Estado de completado
              SwitchListTile(
                title: const Text('Completada'),
                value: _isCompleted,
                onChanged:
                    null, // No permitir cambiar aquí, solo en la vista principal
                secondary: Icon(
                  _isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _isCompleted ? Colors.green : primaryColor,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
