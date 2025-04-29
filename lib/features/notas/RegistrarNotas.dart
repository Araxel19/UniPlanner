import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/db/sqlite_helper.dart';

class RegistrarNotas extends StatefulWidget {
  final int courseId;
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
  final SQLiteHelper _dbHelper = SQLiteHelper();
  List<Map<String, dynamic>> _grades = [];
  Map<int, Map<String, List<double>>> _periodGrades = {};
  Map<int, double> _periodAverages = {};
  double _finalGrade = 0.0;
  bool _isLoading = true;
  Map<int, bool> _expandedPeriods = {1: false, 2: false, 3: false};

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final grades = await _dbHelper.getCourseGrades(widget.courseId);
      final averageData = await _dbHelper.calculateCourseAverage(widget.courseId);

      final Map<int, Map<String, List<double>>> periodGrades = {};
      for (var grade in grades) {
        final period = grade['period'] as int;
        final type = grade['type'] as String;
        final value = grade['value'] as double;
        
        if (!periodGrades.containsKey(period)) {
          periodGrades[period] = {
            'homework': [],
            'self_eval': [],
            'partial': [],
          };
        }
        
        if (periodGrades[period]!.containsKey(type)) {
          periodGrades[period]![type]!.add(value);
        }
      }

      setState(() {
        _grades = grades;
        _periodGrades = periodGrades;
        _periodAverages = Map<int, double>.from(averageData['periodAverages'] as Map);
        _finalGrade = (averageData['finalAverage'] as num).toDouble();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addGrade({
    required String type,
    required int period,
    required double value,
  }) async {
    await _dbHelper.addGrade(
      courseId: widget.courseId,
      type: type,
      period: period,
      value: value,
      weight: 1.0, // Ponderación fija en 1.0
    );
    await _loadGrades();
  }

  Future<void> _updateGrade({
    required int id,
    required double value,
  }) async {
    await _dbHelper.updateGrade(
      id: id,
      value: value,
      weight: 1.0, // Ponderación fija en 1.0
    );
    await _loadGrades();
  }

  Future<void> _deleteGrade(int id) async {
    await _dbHelper.deleteGrade(id);
    await _loadGrades();
  }

  Widget _buildPeriodSection(int period, ThemeData theme, bool isDarkMode) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        key: Key('period_$period'),
        initiallyExpanded: _expandedPeriods[period] ?? false,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedPeriods[period] = expanded;
          });
        },
        title: Row(
          children: [
            Text(
              'Corte $period',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              'Promedio: ${_periodAverages[period]?.toStringAsFixed(2) ?? '0.00'}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getGradeColor(_periodAverages[period] ?? 0.0),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildGradeTypeSection(
                  'Trabajos/Quices (30%)',
                  _grades.where((g) => g['period'] == period && g['type'] == 'homework').toList(),
                  period,
                  'homework',
                  theme,
                ),
                
                _buildGradeTypeSection(
                  'Autoevaluación (10%)',
                  _grades.where((g) => g['period'] == period && g['type'] == 'self_eval').toList(),
                  period,
                  'self_eval',
                  theme,
                ),
                
                _buildGradeTypeSection(
                  'Parcial (60%)',
                  _grades.where((g) => g['period'] == period && g['type'] == 'partial').toList(),
                  period,
                  'partial',
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
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
        SizedBox(height: 8),
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
              icon: Icon(Icons.add, size: 20),
              onPressed: () => _showAddGradeDialog(period, type, title.split(' ')[0]),
            ),
          ],
        ),
        if (grades.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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
            grade['id'] as int,
            grade['type'] as String,
            grade['period'] as int,
          ),
        Divider(),
      ],
    );
  }

  void _showAddGradeDialog(int period, String type, String label) {
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar nota para $label (Corte $period)'),
          content: TextField(
            controller: gradeController,
            decoration: InputDecoration(
              labelText: 'Nota (0.0 - 5.0)',
              hintText: 'Ej: 4.5',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final grade = double.tryParse(gradeController.text) ?? 0.0;
                if (grade >= 0 && grade <= 5.0) {
                  await _addGrade(
                    type: type,
                    period: period,
                    value: grade,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('La nota debe estar entre 0.0 y 5.0')),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradeItem(double grade, int? id, String type, int period) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text('Nota: ${grade.toStringAsFixed(1)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, size: 20),
            onPressed: () => _showEditGradeDialog(id!, grade, type, period),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 20),
            onPressed: () => _deleteGrade(id!),
          ),
        ],
      ),
    );
  }

  void _showEditGradeDialog(int id, double currentGrade, String type, int period) {
    final gradeController = TextEditingController(text: currentGrade.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar nota'),
          content: TextField(
            controller: gradeController,
            decoration: InputDecoration(
              labelText: 'Nota',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final newGrade = double.tryParse(gradeController.text) ?? 0.0;
                if (newGrade >= 0 && newGrade <= 5.0) {
                  await _updateGrade(
                    id: id,
                    value: newGrade,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('La nota debe estar entre 0.0 y 5.0')),
                  );
                }
              },
              child: Text('Guardar'),
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.courseName),
        backgroundColor: isDarkMode ? theme.primaryColor : Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadGrades,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var period in [1, 2, 3])
                    _buildPeriodSection(period, theme, isDarkMode),
                  
                  // Nota final
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Nota Final',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _finalGrade.toStringAsFixed(2),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(_finalGrade),
                            ),
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
}