import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/db/sqlite_helper.dart';
import '../../shared_widgets/general/app_routes.dart';

class EditTaskReminderScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final int userId;
  final List<String> availableLists;

  const EditTaskReminderScreen({
    Key? key,
    required this.task,
    required this.userId,
    required this.availableLists,
  }) : super(key: key);

  @override
  State<EditTaskReminderScreen> createState() => _EditTaskReminderScreenState();
}

class _EditTaskReminderScreenState extends State<EditTaskReminderScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final SQLiteHelper _dbHelper = SQLiteHelper();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController = TextEditingController(
      text: widget.task['description'] ?? '',
    );

    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.task['dueDate']);

    final timeParts = widget.task['dueTime'].split(':');
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

  Future<void> _updateTask() async {
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa un título');
      return;
    }

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await _dbHelper.updateTask(
        widget.task['id'],
        _titleController.text,
        formattedDate,
        formattedTime,
        _descriptionController.text,
        false,
        widget.task['listName'] ?? 'Ideas',
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    const buttonColor = Color(0xFF6750A4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de título
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

            // Selector de hora
            ListTile(
              title: Text('Hora: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) setState(() => _selectedTime = time);
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
            // Selector de lista
            ListTile(
              title: const Text('Lista'),
              trailing: DropdownButton<String>(
                value: widget.task['listName'] ?? 'Ideas',
                items: widget.availableLists.map((list) {
                  return DropdownMenuItem(
                    value: list,
                    child: Text(list),
                  );
                }).toList(),
                onChanged: (newList) {
                  setState(() {
                    widget.task['listName'] = newList;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
