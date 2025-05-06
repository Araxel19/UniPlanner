import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventReminderScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final String userId;

  const EditEventReminderScreen({
    Key? key,
    required this.event,
    required this.userId,
  }) : super(key: key);

  @override
  State<EditEventReminderScreen> createState() =>
      _EditEventReminderScreenState();
}

class _EditEventReminderScreenState extends State<EditEventReminderScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Usar sintaxis de mapa para acceder a los valores
    _titleController = TextEditingController(text: widget.event['title']);
    _descriptionController = TextEditingController(
      text: widget.event['description'] ?? '',
    );

    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.event['date']);

    final startParts = widget.event['startTime'].split(':');
    _startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    final endParts = widget.event['endTime'].split(':');
    _endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa un título');
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final startTimeStr = _formatTime(_startTime);
    final endTimeStr = _formatTime(_endTime);

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes < startMinutes) {
      _showErrorDialog('La hora de fin no puede ser anterior a la de inicio');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('events')
          .doc(widget.event['id'])
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
      _showErrorDialog('Error al actualizar el evento: $e');
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
    final textColor = isDarkMode ? Colors.white : Colors.black;
    const buttonColor = Color(0xFF65558F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Selector de fecha
            ListTile(
              title: Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),

            // Selector de hora de inicio
            ListTile(
              title: Text('Hora inicio: ${_startTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (time != null) setState(() => _startTime = time);
              },
            ),

            // Selector de hora de fin
            ListTile(
              title: Text('Hora fin: ${_endTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _endTime,
                );
                if (time != null) {
                  final start = _startTime.hour * 60 + _startTime.minute;
                  final end = time.hour * 60 + time.minute;
                  if (end < start) {
                    _showErrorDialog(
                        'La hora de fin no puede ser anterior a la de inicio');
                  } else {
                    setState(() => _endTime = time);
                  }
                }
              },
            ),

            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
