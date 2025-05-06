import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditEvento extends StatefulWidget {
  final dynamic event;
  final int userId;

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

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los valores del evento
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);

    // Parsear la fecha y hora del evento
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
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa un título');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('Debes iniciar sesión');
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final startTimeStr = _formatTime(_startTime);
    final endTimeStr = _formatTime(_endTime);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(widget.event.id) // Usar el ID del documento existente
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor =
        isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFD9D9D9);
    final chipColor =
        isDarkMode ? const Color(0xFF444444) : const Color(0xFFFEF7FF);
    const buttonColor = Color(0xFF65558F);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.chevron_left,
                                size: 24, color: textColor),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Editar Evento',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              height: 1.4,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _updateEvent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Actualizar',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Título del evento',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: TextStyle(color: textColor),
                ),

                const SizedBox(height: 16),

                // Fecha
                ListTile(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  leading: Icon(Icons.calendar_today, color: textColor),
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(color: textColor),
                  ),
                ),

                // Hora inicio
                ListTile(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (time != null) setState(() => _startTime = time);
                  },
                  leading: Icon(Icons.access_time, color: textColor),
                  title: Text(
                    _startTime.format(context),
                    style: TextStyle(color: textColor),
                  ),
                ),

                // Hora fin
                ListTile(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (time != null) {
                      final startMinutes =
                          _startTime.hour * 60 + _startTime.minute;
                      final endMinutes = time.hour * 60 + time.minute;
                      if (endMinutes < startMinutes) {
                        _showErrorDialog(
                            'La hora de fin no puede ser anterior a la de inicio');
                      } else {
                        setState(() => _endTime = time);
                      }
                    }
                  },
                  leading: Icon(Icons.access_time_outlined, color: textColor),
                  title: Text(
                    _endTime.format(context),
                    style: TextStyle(color: textColor),
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Descripción del evento',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    filled: true,
                    fillColor: chipColor,
                  ),
                  style: TextStyle(color: textColor),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
