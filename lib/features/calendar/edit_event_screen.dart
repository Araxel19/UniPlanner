import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditEvento extends StatefulWidget {
  final dynamic event;
  final String userId;

  const EditEvento({Key? key, required this.event, required this.userId})
      : super(key: key);

  @override
  State<EditEvento> createState() => _EditEventoState();
}

class _EditEventoState extends State<EditEvento> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.event.date);

    final startTimeParts = widget.event.startTime.split(':');
    _startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );

    final endTimeParts = widget.event.endTime.split(':');
    _endTime = TimeOfDay(
      hour: int.parse(endTimeParts[0]),
      minute: int.parse(endTimeParts[1]),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('Debes iniciar sesión');
        return;
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final startTimeStr = _formatTime(_startTime);
      final endTimeStr = _formatTime(_endTime);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(widget.event.id)
          .update({
        'title': _titleController.text,
        'date': formattedDate,
        'startTime': startTimeStr,
        'endTime': endTimeStr,
        'description': _descriptionController.text,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) setState(() => _startTime = time);
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = time.hour * 60 + time.minute;
      if (endMinutes < startMinutes) {
        _showErrorDialog('La hora de fin debe ser posterior a la de inicio');
      } else {
        setState(() => _endTime = time);
      }
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _updateEvent,
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
                        onTap: _selectDate,
                        leading: Icon(Icons.calendar_today, color: primaryColor),
                        title: const Text('Fecha'),
                        subtitle: Text(
                          DateFormat('EEEE, d MMMM y').format(_selectedDate),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const Divider(),

                      // Hora inicio
                      ListTile(
                        onTap: _selectStartTime,
                        leading: Icon(Icons.access_time, color: primaryColor),
                        title: const Text('Hora de inicio'),
                        subtitle: Text(
                          _startTime.format(context),
                          style: TextStyle(color: onSurfaceColor),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const Divider(),

                      // Hora fin
                      ListTile(
                        onTap: _selectEndTime,
                        leading: Icon(Icons.access_time_outlined, color: primaryColor),
                        title: const Text('Hora de fin'),
                        subtitle: Text(
                          _endTime.format(context),
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