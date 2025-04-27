import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/db/sqlite_helper.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({Key? key}) : super(key: key);

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final SQLiteHelper _dbHelper = SQLiteHelper();
  int? _userId;
  List<String> _lists = ['Hoy', 'Ideas'];
  String _selectedList = 'Ideas';
  Map<String, bool> _completedTasksVisibility = {};
  late Future<SharedPreferences> _prefsFuture;
  bool _showCompletedTasks = false;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
    _loadUserId();
    _loadLists();
  }

  Future<void> _loadLists() async {
    final prefs = await _prefsFuture;
    final savedLists = prefs.getStringList('taskLists') ?? [];

    setState(() {
      // Combinar listas básicas con las guardadas, eliminando duplicados
      _lists = ['Hoy', 'Ideas']
        ..addAll(savedLists.where((list) => !['Hoy', 'Ideas'].contains(list)));

      for (var list in _lists) {
        _completedTasksVisibility[list] = false;
      }

      // Guardar la lista combinada para futuras cargas
      prefs.setStringList('taskLists',
          _lists.where((l) => l != 'Hoy' && l != 'Ideas').toList());
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  Future<List<Map<String, dynamic>>> _getTasksForList() async {
    if (_userId == null) return [];
    return await _dbHelper.getTasksForList(_selectedList, _userId!);
  }

  Future<List<Map<String, dynamic>>> _getTodayTasks() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await _dbHelper.getTasksForDay(formattedDate, userId: _userId);
  }

  Future<void> _toggleTaskCompletion(int taskId, bool isCompleted) async {
    await _dbHelper.updateTaskCompletion(taskId, isCompleted);
    setState(() {});
  }

  // En tu pantalla principal (RecordatoriosScreen)
  void _showAddTaskDialog(BuildContext context) {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión primero')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.addTaskReminderScreen,
      arguments: {
        'userId': _userId,
        'defaultList': _selectedList == 'Hoy' ? 'Ideas' : _selectedList,
        'availableLists': _lists
            .where((l) => l != 'Hoy')
            .toList(), // Excluye 'Hoy' si es necesario
      },
    ).then((_) => setState(() {}));
  }

  void _showAddListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nueva lista'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nombre de la lista',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final prefs = await _prefsFuture;
                  setState(() {
                    _lists.add(controller.text);
                    _completedTasksVisibility[controller.text] = false;
                    _selectedList = controller.text;
                    prefs.setStringList('taskLists', _lists);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameListDialog(BuildContext context, String currentName) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller =
            TextEditingController(text: currentName);
        return AlertDialog(
          title: const Text('Renombrar lista'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nuevo nombre de la lista',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty &&
                    controller.text != currentName) {
                  try {
                    final prefs = await _prefsFuture;
                    await _dbHelper.renameTaskList(
                        currentName, controller.text, _userId!);
                    setState(() {
                      final index = _lists.indexOf(currentName);
                      _lists[index] = controller.text;
                      _selectedList = controller.text;
                      _completedTasksVisibility[controller.text] =
                          _completedTasksVisibility[currentName] ?? false;
                      _completedTasksVisibility.remove(currentName);
                      prefs.setStringList('taskLists', _lists);
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al renombrar: $e')),
                    );
                  }
                }
              },
              child: const Text('Renombrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteList(String listName) async {
    if (listName == 'Ideas' || listName == 'Hoy') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar esta lista'),
        ),
      );
      return;
    }

    final isEmpty = await _dbHelper.isListEmpty(listName, _userId!);
    if (!isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar una lista con tareas'),
        ),
      );
      return;
    }

    final prefs = await _prefsFuture;
    setState(() {
      _lists.remove(listName);
      _completedTasksVisibility.remove(listName);
      if (_selectedList == listName) {
        _selectedList = 'Ideas';
      }
      // Actualizar SharedPreferences
      prefs.setStringList(
          'taskLists', _lists.where((l) => l != listName).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
      ),
      body: Column(
        children: [
          // Selector de listas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _lists.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _lists.length) {
                  return InkWell(
                    onTap: () => _showAddListDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 4),
                          Text('Nueva lista'),
                        ],
                      ),
                    ),
                  );
                }
                final listName = _lists[index];
                return Row(
                  children: [
                    ChoiceChip(
                      label: Text(listName),
                      selected: _selectedList == listName,
                      onSelected: (selected) {
                        setState(() => _selectedList = listName);
                      },
                    ),
                    if (_selectedList == listName &&
                        listName != 'Ideas' &&
                        listName != 'Hoy')
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'rename',
                            child: Row(
                              children: const [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Renombrar lista'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar lista',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'rename') {
                            _showRenameListDialog(context, listName);
                          } else if (value == 'delete') {
                            _deleteList(listName);
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedList == 'Hoy'
                ? _buildTodayTasksList()
                : _buildTasksList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildTasksList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTasksForList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar tareas',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final tasks = snapshot.data!;
        final pendingTasks = tasks.where((t) => t['isCompleted'] != 1).toList();
        final completedTasks =
            tasks.where((t) => t['isCompleted'] == 1).toList();

        if (pendingTasks.isEmpty && completedTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay tareas en "$_selectedList"',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tareas pendientes
            ...pendingTasks.map((task) => _buildTaskItem(task)).toList(),

            // Tareas completadas con opción para mostrar/ocultar
            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCompletedTasks = !_showCompletedTasks;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tareas Completadas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      _showCompletedTasks
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_showCompletedTasks)
                ...completedTasks.map((task) => _buildTaskItem(task)).toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTodayTasksList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTodayTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar tareas',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Filtrar solo tareas no completadas para la vista de Hoy
        final todayTasks =
            snapshot.data!.where((task) => task['isCompleted'] != 1).toList();

        if (todayTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.today, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay tareas pendientes para hoy',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todayTasks.length,
          itemBuilder: (context, index) => _buildTaskItem(todayTasks[index]),
        );
      },
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final isCompleted = task['isCompleted'] == 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) => _toggleTaskCompletion(task['id'], !isCompleted),
        ),
        title: Text(
          task['title'],
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task['description']?.toString().isNotEmpty == true)
              Text(task['description']),
            if (task['dueTime'] != null)
              Text('${task['dueTime']} - ${task['dueDate']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'move',
              child: Row(
                children: [
                  Icon(Icons.move_to_inbox, size: 20),
                  SizedBox(width: 8),
                  Text('Mover a otra lista'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.pushNamed(
                context,
                AppRoutes.editReminderTask,
                arguments: {
                  'task': task,
                  'userId': _userId,
                  'availableLists': _lists,
                },
              );
              setState(() {});
            } else if (value == 'move') {
              _showMoveTaskDialog(context, task['id']);
            }
          },
        ),
      ),
    );
  }

  void _showMoveTaskDialog(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mover tarea a'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _lists.length,
              itemBuilder: (context, index) {
                final list = _lists[index];
                if (list == _selectedList) return const SizedBox();
                return ListTile(
                  title: Text(list),
                  onTap: () {
                    _moveTaskToList(taskId, list);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _moveTaskToList(int taskId, String listName) async {
    await _dbHelper.updateTaskList(taskId, listName);
    setState(() {});
  }
}
