import 'package:flutter/material.dart';
import '../../core/db/firestore_service.dart';
import '../../shared_widgets/general/app_routes.dart';

class RegistrarCurso extends StatefulWidget {
  const RegistrarCurso({Key? key}) : super(key: key);

  @override
  _RegistrarCursoState createState() => _RegistrarCursoState();
}

class _RegistrarCursoState extends State<RegistrarCurso> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.addCourse(
          _nameController.text,
          label: _labelController.text,
        );

        if (!mounted) return;
        Navigator.pop(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.calculadora),
        ),
        title: const Text('Registrar Curso'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isDarkMode),
                      _buildForm(isDarkMode),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Ingrese tu nuevo curso',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildForm(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre del curso',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Ej: Cálculo Multivariable',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: isDarkMode,
            fillColor: isDarkMode ? Colors.grey[800] : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[400]! : Colors.grey[500]!,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el nombre del curso';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Etiqueta (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _labelController,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Ej: Matemáticas, Ciencias, etc.',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: isDarkMode,
            fillColor: isDarkMode ? Colors.grey[800] : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[400]! : Colors.grey[500]!,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    backgroundColor: isDarkMode
                        ? Colors.blueAccent
                        : const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: Icon(Icons.save,
                      color: isDarkMode ? Colors.white : Colors.white),
                  label: const Text(
                    'Guardar Curso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
