import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../core/db/sqlite_helper.dart';
import '../../shared_widgets/general/app_routes.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({Key? key}) : super(key: key);

  @override
  _CalculadoraState createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  final SQLiteHelper _dbHelper = SQLiteHelper();
  List<Map<String, dynamic>> _courses = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    if (userEmail != null) {
      final user = await _dbHelper.getUserByEmail(userEmail);
      if (user != null) {
        setState(() {
          _userId = user['id'] as int;
        });
        _loadCourses();
      }
    }
  }

  Future<void> _loadCourses() async {
    if (_userId == null) return;
    final courses = await _dbHelper.getUserCourses(_userId!);
    setState(() {
      _courses = courses;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Mis cursos',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCourseList(theme, isDarkMode, context),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                                context, AppRoutes.registrarCurso);
                            if (_userId != null) {
                              await _loadCourses();
                            }
                          },
                          backgroundColor: isDarkMode
                              ? theme.colorScheme.primaryContainer
                              : const Color(0xFFECE6F0),
                          elevation: 2,
                          child: Icon(
                            Icons.add,
                            size: 28,
                            color: isDarkMode
                                ? theme.colorScheme.onPrimaryContainer
                                : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(
      ThemeData theme, bool isDarkMode, BuildContext context) {
    if (_courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No tienes cursos registrados',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var course in _courses)
          Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.school,
                  size: 32,
                  color: isDarkMode ? Colors.white : Colors.blueAccent,
                ),
                title: Text(
                  course['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Ver notas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.registrarNotas,
                      arguments: {
                        'courseId': course['id'],
                        'courseName': course['name'],
                      },
                    );
                  },
                ),
                onTap: () async {
                  final shouldRefresh = await Navigator.pushNamed(
                    context,
                    AppRoutes.editarCurso,
                    arguments: {
                      'courseId': course['id'],
                      'courseName': course['name'],
                      'courseLabel': course['label'] ?? '',
                    },
                  );

                  if (shouldRefresh == true) {
                    await _loadCourses();
                  }
                },
              ),
              const Divider(height: 1),
            ],
          ),
      ],
    );
  }
}
