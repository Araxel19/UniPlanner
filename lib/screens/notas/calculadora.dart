import 'package:flutter/material.dart';
import '../../widgets/notas/course_list_item.dart';
import '../../widgets/bottom_navigation.dart';
import 'registrar_curso.dart';

class Calculadora extends StatelessWidget {
  const Calculadora({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'Mis cursos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildCourseList(),
                      // Botón flotante posicionado debajo del último curso
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrarCurso(),
                                ),
                              );
                            },
                            backgroundColor: const Color(0xFFECE6F0),
                            elevation: 8,
                            child: const Icon(
                              Icons.add,
                              size: 36,
                              color: Colors.black,
                            ),
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

  Widget _buildCourseList() {
    return Column(
      children: [
        CourseListItem(
          courseName: 'Inglés 2',
          subtitle: 'BOTTOM OVERLOVED BY 22 FIXELS',
        ),
        CourseListItem(
          courseName: 'Cálculo Multivariable',
          subtitle: 'BOTTOM OVERLOVED BY 22 FIXELS',
        ),
        CourseListItem(
          courseName: 'Cloud Computing',
          subtitle: 'BOTTOM OVERLOVED BY 22 FIXELS',
        ),
        CourseListItem(
          courseName: 'Aplicaciones Móviles',
          hasSubItems: true,
          subItems: const ['Calendario', 'Recordatorios', 'Finanzas', 'Notas'],
        ),
        CourseListItem(
          courseName: 'Programación en JAVA',
        ),
      ],
    );
  }
}
