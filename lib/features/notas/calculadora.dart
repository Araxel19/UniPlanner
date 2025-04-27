import 'package:flutter/material.dart';
import '../../shared_widgets/notas/course_list_item.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import 'registrar_curso.dart';
import 'EditarCurso.dart'; // Importa el archivo EditarCurso.dart
import 'RegistrarNotas.dart'; // Importa el archivo RegistrarNotas.dart

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
                      _buildCourseList(theme, isDarkMode, context),
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

  Widget _buildCourseList(
      ThemeData theme, bool isDarkMode, BuildContext context) {
    return Column(
      children: [
        _CustomCourseListItem(
          courseName: 'Inglés 2',
          subtitle: '3.5',
          theme: theme,
          isDarkMode: isDarkMode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const EditarCurso(), // Navega a EditarCurso
              ),
            );
          },
          onArrowPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const RegistrarNotas(), // Navega a RegistrarNotas
              ),
            );
          },
        ),
        const Divider(height: 1),
        _CustomCourseListItem(
          courseName: 'Cálculo Multivariable',
          subtitle: '4.6',
          theme: theme,
          isDarkMode: isDarkMode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const EditarCurso(), // Navega a EditarCurso
              ),
            );
          },
          onArrowPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const RegistrarNotas(), // Navega a RegistrarNotas
              ),
            );
          },
        ),
        const Divider(height: 1),
        _CustomCourseListItem(
          courseName: 'Cloud Computing',
          subtitle: '4.9',
          theme: theme,
          isDarkMode: isDarkMode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const EditarCurso(), // Navega a EditarCurso
              ),
            );
          },
          onArrowPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const RegistrarNotas(), // Navega a RegistrarNotas
              ),
            );
          },
        ),
        const Divider(height: 1),
        _CustomCourseListItem(
          courseName: 'Programación en JAVA',
          subtitle: '5.0',
          theme: theme,
          isDarkMode: isDarkMode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const EditarCurso(), // Navega a EditarCurso
              ),
            );
          },
          onArrowPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const RegistrarNotas(), // Navega a RegistrarNotas
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget personalizado para mostrar un curso con un ícono de carpeta
class _CustomCourseListItem extends StatelessWidget {
  final String courseName;
  final String subtitle;
  final ThemeData theme;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onArrowPressed;

  const _CustomCourseListItem({
    Key? key,
    required this.courseName,
    required this.subtitle,
    required this.theme,
    required this.isDarkMode,
    required this.onTap,
    required this.onArrowPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.folder, // Ícono de carpeta
        size: 32,
        color: isDarkMode ? Colors.white : Colors.blueAccent,
      ),
      title: Text(
        courseName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: InkWell(
        onTap: onArrowPressed, // Acción al presionar la flecha
        child: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      onTap: onTap, // Acción al presionar el resto del ListTile
    );
  }
}
