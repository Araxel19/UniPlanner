import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskReminderScreen extends StatefulWidget {
  final String userId; // Cambiado a String
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String _selectedList;

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      _showError('Por favor ingresa un título');
      return;
    }

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
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

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al guardar: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
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
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
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
                labelText: 'Lista',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
