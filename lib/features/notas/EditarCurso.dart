import 'package:flutter/material.dart';

class EditarCurso extends StatefulWidget {
  final int courseId;
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del curso',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Etiqueta (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí deberías implementar la lógica para guardar los cambios
                Navigator.pop(context);
              },
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}