import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared_widgets/general/app_routes.dart';
import '../../core/db/sqlite_helper.dart';

class EditTaskScreen extends StatefulWidget {
  final dynamic task;
  final int userId;

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
  final SQLiteHelper _dbHelper = SQLiteHelper();

  @override
  void initState() {
    super.initState();

    // Manejar tanto Map como objeto Task
    final dynamic taskData = widget.task;
    _titleController = TextEditingController(
        text: taskData is Map ? taskData['title'] : taskData.title);

    _descriptionController = TextEditingController(
        text: taskData is Map
            ? taskData['description'] ?? ''
            : taskData.description ?? '');

    // Parsear fecha
    final dueDate = taskData is Map ? taskData['dueDate'] : taskData.dueDate;
    _selectedDate = DateFormat('yyyy-MM-dd').parse(dueDate);

    // Parsear hora
    final dueTime = taskData is Map ? taskData['dueTime'] : taskData.dueTime;
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
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa un título');
      return;
    }

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      // Asegurarse de que taskData es un Map
      final Map<String, dynamic> taskData = widget.task is Map
          ? widget.task
          : {
              'id': widget.task.id,
              'title': widget.task.title,
              'description': widget.task.description,
              'dueDate': widget.task.dueDate,
              'dueTime': widget.task.dueTime,
              'isCompleted': widget.task.isCompleted,
              'listName': widget.task.listName ?? 'Ideas',
            };

      await _dbHelper.updateTask(
        taskData['id'],
        _titleController.text,
        formattedDate,
        formattedTime,
        _descriptionController.text,
        taskData['isCompleted'] ?? false,
        taskData['listName'] ?? 'Ideas', // Usar el valor del Map
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al actualizar la tarea: $e');
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
    const buttonColor = Color(0xFF6750A4);

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
                                color: textColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Editar Tarea',
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
                        onTap: _updateTask,
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
                    hintText: 'Título de la tarea',
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
                  onTap: _selectDate,
                  leading: Icon(Icons.calendar_today, color: textColor),
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(color: textColor),
                  ),
                ),

                // Hora
                ListTile(
                  onTap: _selectTime,
                  leading: Icon(Icons.access_time, color: textColor),
                  title: Text(
                    _selectedTime.format(context),
                    style: TextStyle(color: textColor),
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Descripción de la tarea',
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
