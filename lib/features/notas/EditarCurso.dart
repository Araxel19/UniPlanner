import 'package:flutter/material.dart';
import '../../core/db/firestore_service.dart';

class EditarCurso extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String courseLabel;

  const EditarCurso({
    Key? key,
    required this.courseId,
    required this.courseName,
    this.courseLabel = '',
  }) : super(key: key);

  @override
  EditarCursoState createState() => EditarCursoState();
}

class EditarCursoState extends State<EditarCurso> {
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.courseName;
    _labelController.text = widget.courseLabel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateCourse(
        widget.courseId,
        _nameController.text,
        label: _labelController.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.deleteCourse(widget.courseId);
        if (!mounted) return;
        Navigator.pop(context, true);
      } finally {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Curso'),
        backgroundColor: isDarkMode ? theme.primaryColor : Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            color: Colors.red,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del curso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Etiqueta (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
    );
  }
}
