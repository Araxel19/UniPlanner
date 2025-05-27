import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/db/firestore_service.dart';

class RegistrarNotas extends StatefulWidget {
  final String courseId;
  final String courseName;

  const RegistrarNotas({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  _RegistrarNotasState createState() => _RegistrarNotasState();
}

class _RegistrarNotasState extends State<RegistrarNotas> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _grades = [];
  Map<int, Map<String, List<double>>> _periodGrades = {};
  Map<int, double> _periodAverages = {};
  double _finalGrade = 0.0;
  bool _isLoading = true;
  final Map<int, bool> _expandedPeriods = {1: false, 2: false, 3: false};

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);

    try {
      final grades = await _firestoreService.getCourseGrades(widget.courseId);
      final averageData =
          await _firestoreService.calculateCourseAverage(widget.courseId);

      final Map<int, Map<String, List<double>>> periodGrades = {
        1: {'homework': [], 'self_eval': [], 'partial': []},
        2: {'homework': [], 'self_eval': [], 'partial': []},
        3: {'homework': [], 'self_eval': [], 'partial': []},
      };

      for (var grade in grades) {
        final period = grade['period'] as int;
        final type = grade['type'] as String;
        final value = grade['value'] as double;

        if (periodGrades.containsKey(period) &&
            periodGrades[period]!.containsKey(type)) {
          periodGrades[period]![type]!.add(value);
        }
      }

      setState(() {
        _grades = grades;
        _periodGrades = periodGrades;
        _periodAverages =
            Map<int, double>.from(averageData['periodAverages'] as Map);
        _finalGrade = (averageData['finalAverage'] as num).toDouble();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las notas: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addGrade({
    required String type,
    required int period,
    required double value,
  }) async {
    try {
      await _firestoreService.addGrade(
        courseId: widget.courseId,
        type: type,
        period: period,
        value: value,
        weight: 1.0,
      );
      await _loadGrades();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota agregada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar nota: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateGrade({
    required String id,
    required double value,
  }) async {
    try {
      await _firestoreService.updateGrade(
        gradeId: id,
        value: value,
        weight: 1.0,
      );
      await _loadGrades();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota actualizada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar nota: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteGrade(String id) async {
    try {
      await _firestoreService.deleteGrade(id);
      await _loadGrades();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar nota: ${e.toString()}')),
      );
    }
  }

  Widget _buildPeriodSection(int period, ThemeData theme, bool isDarkMode) {
    final periodAverage = _periodAverages[period] ?? 0.0;
    final isPassingPeriod = periodAverage >= 3.0;
    final canPassCourse = _calculateCanPassCourse(period);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        key: Key('period_$period'),
        initiallyExpanded: _expandedPeriods[period] ?? false,
        onExpansionChanged: (expanded) {
          setState(() => _expandedPeriods[period] = expanded);
        },
        leading: Icon(
          isPassingPeriod ? Icons.check_circle : Icons.warning,
          color: isPassingPeriod ? Colors.green : Colors.orange,
        ),
        title: Row(
          children: [
            Text(
              'Corte $period',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Promedio: ${periodAverage.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(periodAverage),
                  ),
                ),
                if (period == 2 && canPassCourse)
                  Text(
                    '¡Podrías pasar la materia!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildGradeTypeSection(
                  'Trabajos/Quices (30%)',
                  _grades
                      .where((g) =>
                          g['period'] == period && g['type'] == 'homework')
                      .toList(),
                  period,
                  'homework',
                  theme,
                ),
                _buildGradeTypeSection(
                  'Autoevaluación (10%)',
                  _grades
                      .where((g) =>
                          g['period'] == period && g['type'] == 'self_eval')
                      .toList(),
                  period,
                  'self_eval',
                  theme,
                ),
                _buildGradeTypeSection(
                  'Parcial (60%)',
                  _grades
                      .where((g) =>
                          g['period'] == period && g['type'] == 'partial')
                      .toList(),
                  period,
                  'partial',
                  theme,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estado:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      isPassingPeriod ? 'Aprobado' : 'No aprobado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPassingPeriod ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (!isPassingPeriod || period == 2)
                  TextButton(
                    onPressed: () => _showRequiredGradesDialog(period),
                    child: Text(
                      period == 2
                          ? '¿Qué necesito en el tercer corte?'
                          : '¿Qué necesito para pasar?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _calculateCanPassCourse(int currentPeriod) {
    if (currentPeriod != 2) return false;

    final first = _periodAverages[1] ?? 0.0;
    final second = _periodAverages[2] ?? 0.0;

    // Pesos reales: 33% para el primero, 33% para el segundo y 34% para el tercero
    // Para saber si podría pasar sin el tercer corte, asumimos que saca 0.0 en el tercero
    final weightedAverage =
        (first * 0.33) + (second * 0.33); // tercer corte = 0

    return weightedAverage >= 3.0;
  }

  void _showRequiredGradesDialog(int period) {
    final first = _periodAverages[1] ?? 0.0;
    final second = _periodAverages[2] ?? 0.0;
    final current = _periodAverages[period] ?? 0.0;

    double neededThird = 0.0;

    if (period == 2) {
      // (first * 0.33) + (second * 0.33) + (x * 0.34) >= 3.0
      final required = 3.0 - ((first * 0.33) + (second * 0.33));
      neededThird = (required / 0.34).clamp(0.0, 5.0);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Requisitos para aprobar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'La materia se aprueba con un promedio final de 3.0/5.0.'),
              const SizedBox(height: 12),
              if (period == 2)
                Text(
                  'Promedio actual: Corte 1 = ${first.toStringAsFixed(2)}, Corte 2 = ${second.toStringAsFixed(2)}',
                ),
              const SizedBox(height: 8),
              if (period == 2)
                Text(
                  'Necesitas sacar al menos ${neededThird.toStringAsFixed(2)} en el tercer corte para aprobar.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (period == 3 && _finalGrade < 3.0)
                const Text(
                  'Lo siento, no alcanzaste el promedio mínimo para aprobar la materia.',
                  style: TextStyle(color: Colors.red),
                ),
              if (period == 3 && _finalGrade >= 3.0)
                const Text(
                  '¡Felicidades! Has aprobado la materia.',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradeTypeSection(
    String title,
    List<Map<String, dynamic>> grades,
    int period,
    String type,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Agregar nota',
              onPressed: () =>
                  _showAddGradeDialog(period, type, title.split(' ')[0]),
            ),
          ],
        ),
        if (grades.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No hay notas registradas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        for (var grade in grades)
          _buildGradeItem(
            grade['value'] as double,
            grade['id'] as String,
            grade['type'] as String,
            grade['period'] as int,
          ),
        const Divider(),
      ],
    );
  }

  void _showAddGradeDialog(int period, String type, String label) {
    final gradeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar nota para $label (Corte $period)'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: gradeController,
              decoration: const InputDecoration(
                labelText: 'Nota (0.0 - 5.0)',
                hintText: 'Ej: 4.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese una nota';
                final grade = double.tryParse(value) ?? 0.0;
                if (grade < 0 || grade > 5.0) {
                  return 'La nota debe estar entre 0.0 y 5.0';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final grade = double.tryParse(gradeController.text) ?? 0.0;
                  await _addGrade(
                    type: type,
                    period: period,
                    value: grade,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradeItem(double grade, String id, String type, int period) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: ListTile(
        title: Text(
          'Nota: ${grade.toStringAsFixed(1)}',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Editar nota',
              onPressed: () => _showEditGradeDialog(id, grade, type, period),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              tooltip: 'Eliminar nota',
              onPressed: () => _showDeleteConfirmationDialog(id),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteGrade(id);
                Navigator.pop(context);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditGradeDialog(
      String id, double currentGrade, String type, int period) {
    final gradeController =
        TextEditingController(text: currentGrade.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar nota'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: gradeController,
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese una nota';
                final grade = double.tryParse(value) ?? 0.0;
                if (grade < 0 || grade > 5.0) {
                  return 'La nota debe estar entre 0.0 y 5.0';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newGrade = double.tryParse(gradeController.text) ?? 0.0;
                  await _updateGrade(id: id, value: newGrade);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        );
      },
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 4.5) return Colors.green;
    if (grade >= 3.5) return Colors.blue;
    if (grade >= 3.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final passingStatus = _finalGrade >= 3.0 ? 'Aprobado' : 'No aprobado';
    final passingColor = _finalGrade >= 3.0 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.courseName),
        backgroundColor: isDarkMode ? theme.primaryColor : Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar notas',
            onPressed: _loadGrades,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información',
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sección de cortes
                  for (var period in [1, 2, 3])
                    _buildPeriodSection(period, theme, isDarkMode),

                  // Nota final
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(top: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Resultado Final',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _finalGrade.toStringAsFixed(2),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(_finalGrade),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _finalGrade >= 3.0
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color: passingColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                passingStatus,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: passingColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'La materia se aprueba con un promedio final de 3.0/5.0',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Información sobre calificaciones'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sistema de calificación:'),
              SizedBox(height: 8),
              Text('• Trabajos/Quices: 30% del corte'),
              Text('• Autoevaluación: 10% del corte'),
              Text('• Parcial: 60% del corte'),
              SizedBox(height: 16),
              Text('La nota final es el promedio de los 3 cortes.'),
              SizedBox(height: 8),
              Text('Se requiere un mínimo de 3.0/5.0 para aprobar.'),
              SizedBox(height: 16),
              Text(
                'Si en el segundo corte tienes un promedio alto, podrías aprobar sin necesidad del tercer corte.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
