import 'package:flutter/material.dart';
import '../../shared_widgets/general/app_routes.dart';
import '../../core/db/sqlite_helper.dart';
import 'package:intl/intl.dart';

class AggEvento extends StatefulWidget {
  final int userId;

  const AggEvento({Key? key, required this.userId}) : super(key: key);

  @override
  State<AggEvento> createState() => _AggEventoState();
}

class _AggEventoState extends State<AggEvento> {
  bool _isEventSelected = true;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final SQLiteHelper _sqliteHelper = SQLiteHelper();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa un título');
      return;
    }
    if (_selectedDate == null) {
      _showErrorDialog('Por favor selecciona una fecha');
      return;
    }
    if (_startTime == null) {
      _showErrorDialog('Por favor selecciona una hora de inicio');
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final startTimeStr = _formatTime(_startTime!);
    final endTimeStr = _endTime != null ? _formatTime(_endTime!) : startTimeStr;

    if (_endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes < startMinutes) {
        _showErrorDialog('La hora de fin no puede ser anterior a la de inicio');
        return;
      }
    }

    try {
      await _sqliteHelper.addEvent(
        _titleController.text,
        formattedDate,
        startTimeStr,
        endTimeStr,
        _descriptionController.text,
        widget.userId,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al guardar el evento: $e');
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
    final buttonColor = const Color(0xFF65558F);

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
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                                context, AppRoutes.calendario),
                            child: const Icon(Icons.chevron_left, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Evento',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _saveEvent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botones Evento / Tarea
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            setState(() => _isEventSelected = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEventSelected
                              ? buttonColor
                              : buttonColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Evento'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.taskInput,
                            arguments: widget.userId, // Pasa el userId
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isEventSelected
                              ? buttonColor
                              : buttonColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Tarea'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Agregar título',
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
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  leading: Icon(Icons.calendar_today, color: textColor),
                  title: Text(
                    _selectedDate == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: TextStyle(color: textColor),
                  ),
                ),

                // Hora inicio
                ListTile(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime ?? TimeOfDay.now(),
                    );
                    if (time != null) setState(() => _startTime = time);
                  },
                  leading: Icon(Icons.access_time, color: textColor),
                  title: Text(
                    _startTime == null
                        ? 'Seleccionar hora de inicio'
                        : _startTime!.format(context),
                    style: TextStyle(color: textColor),
                  ),
                ),

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
                    );
                    if (time != null) {
                      final startMinutes =
                          _startTime!.hour * 60 + _startTime!.minute;
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
                    _endTime == null
                        ? 'Seleccionar hora de fin'
                        : _endTime!.format(context),
                    style: TextStyle(color: textColor),
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Agregar descripción',
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
