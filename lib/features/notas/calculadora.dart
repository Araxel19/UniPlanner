import 'package:flutter/material.dart';
import '../../shared_widgets/notas/course_list_item.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import 'registrar_curso.dart';

class Calculadora extends StatelessWidget {
  const Calculadora({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal con scroll
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
                      _buildCourseList(theme),
                      const SizedBox(height: 24),
                      // Botón para agregar curso
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrarCurso(),
                              ),
                            );
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
            // Barra de navegación inferior
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(ThemeData theme) {
    return Column(
      children: [
        CourseListItem(
          courseName: 'Inglés 2',
          subtitle: '3.5',
          theme: theme,
        ),
        const Divider(height: 1),
        CourseListItem(
          courseName: 'Cálculo Multivariable',
          subtitle: '4.6',
          theme: theme,
        ),
        const Divider(height: 1),
        CourseListItem(
          courseName: 'Cloud Computing',
          subtitle: '4.9',
          theme: theme,
        ),
        const Divider(height: 1),
        CourseListItem(
          courseName: 'Programación en JAVA',
          subtitle: '5.0',
          theme: theme,
        ),
      ],
    );
  }
}