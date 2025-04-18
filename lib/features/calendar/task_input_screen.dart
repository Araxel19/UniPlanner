import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared_widgets/general/app_routes.dart';
import '../../core/db/sqlite_helper.dart';

class TaskInputScreen extends StatefulWidget {
  final int? userId;

  const TaskInputScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final SQLiteHelper _dbHelper = SQLiteHelper();
  int? _userId;
  bool _isTaskSelected = true;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    if (_userId == null) {
      _loadUserId();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
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

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa un título');
      return;
    }

    if (_userId == null) {
      _showErrorDialog('Debes iniciar sesión primero');
      return;
    }

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await _dbHelper.addTask(
        _titleController.text,
        formattedDate,
        formattedTime,
        _descriptionController.text,
        _userId!,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al guardar: $e');
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor =
        isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFD9D9D9);
    final chipColor =
        isDarkMode ? const Color(0xFF444444) : const Color(0xFFFEF7FF);
    final buttonColor = const Color(0xFF6750A4);

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
                // Header - Igual al de eventos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.calendario),
                            child: Icon(Icons.chevron_left, color: textColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tarea',
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
                        onTap: _saveTask,
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

                // Botones Evento/Tarea - Mejorados
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context, 
                            AppRoutes.addEvent,
                            arguments: _userId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isTaskSelected
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
                        onPressed: () => setState(() => _isTaskSelected = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTaskSelected
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

                // Título - Estilo consistente
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

                // Fecha - Estilo de lista como en eventos
                ListTile(
                  onTap: _selectDate,
                  leading: Icon(Icons.calendar_today, color: textColor),
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(color: textColor),
                  ),
                ),

                // Hora - Estilo de lista como en eventos
                ListTile(
                  onTap: _selectTime,
                  leading: Icon(Icons.access_time, color: textColor),
                  title: Text(
                    _selectedTime.format(context),
                    style: TextStyle(color: textColor),
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción - Estilo consistente
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