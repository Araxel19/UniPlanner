import 'package:flutter/material.dart';
import '../../shared_widgets/general/bottom_navigation.dart';

class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> tareas = const [
    {
      "titulo": "Estudiar para parcial",
      "subtitulo": "Administración de Servidores\n12/03/2025 12:15 am"
    },
    {
      "titulo": "Comprar Leche",
      "subtitulo": "X 3"
    },
    {
      "titulo": "Terminar Taller",
      "subtitulo": "Base de Datos"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Pendientes",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.hintColor,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: "+"),
              Tab(text: "Hoy"),
              Tab(text: "Revisión"),
              Tab(text: "Terminado"),
            ],
          ),
        ),
        body: TabBarView(
          children: List.generate(4, (index) => _buildTaskList(tareas, theme)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: isDarkMode
              ? theme.colorScheme.primaryContainer
              : const Color(0xFFECE6F0),
          child: Icon(
            Icons.add,
            color: isDarkMode
                ? theme.colorScheme.onPrimaryContainer
                : Colors.black,
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }

  static Widget _buildTaskList(List<Map<String, String>> tareas, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          value: true,
          onChanged: (_) {},
          activeColor: theme.colorScheme.primary,
          title: Text(
            tareas[index]["titulo"]!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Text(
            tareas[index]["subtitulo"]!,
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
    );
  }
}

