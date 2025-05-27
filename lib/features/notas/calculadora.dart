import 'package:flutter/material.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../core/db/firestore_service.dart';
import '../../shared_widgets/general/app_routes.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CalculadoraState createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses = await _firestoreService.getUserCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading courses: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar los cursos: ${e.toString()}';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Mis cursos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: _buildCourseContent(theme, isDarkMode),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.registrarCurso);
          await _loadCourses();
        },
        backgroundColor: isDarkMode
            ? theme.colorScheme.primaryContainer
            : const Color(0xFFECE6F0),
        elevation: 4,
        child: Icon(
          Icons.add,
          size: 28,
          color:
              isDarkMode ? theme.colorScheme.onPrimaryContainer : Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildCourseContent(ThemeData theme, bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(theme, isDarkMode);
    }

    if (_courses.isEmpty) {
      return Center(
        child: Text(
          'No tienes cursos registrados',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      child: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(
                Icons.school,
                size: 32,
                color: isDarkMode ? Colors.white : Colors.blueAccent,
              ),
              title: Text(
                course['name'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, bool isDarkMode) {
    return Center(
      child: Column(
        children: [
          Text(
            _errorMessage!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.red[300] : Colors.red[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCourses,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
