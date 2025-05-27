import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({Key? key}) : super(key: key);

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  List<String> _lists = ['Hoy', 'Ideas'];
  String _selectedList = 'Ideas';
  bool _showCompletedTasks = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      await _loadLists();
    }
  }

  Future<void> _loadLists() async {
    if (_userId == null) return;

    try {
      final listsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('taskLists')
          .get();

      setState(() {
        _lists = ['Hoy', 'Ideas', ...listsSnapshot.docs.map((doc) => doc.id)]
          ;
      });
    } catch (e) {
      debugPrint('Error cargando listas: $e');
    }
  }

  Stream<QuerySnapshot> _getTasksForListStream() {
    if (_userId == null || _selectedList == 'Hoy') {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .where('listName', isEqualTo: _selectedList)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> _getTodayTasksStream() {
    if (_userId == null) return const Stream.empty();

    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .where('dueDate', isEqualTo: formattedDate)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteTask(String taskId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      await flutterLocalNotificationsPlugin.show(
        5555,
        'Recordatorio eliminado',
        '¡El recordatorio se eliminó correctamente!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tareas_channel',
            'Tareas y eventos',
            channelDescription: 'Notificaciones de tareas y eventos',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar tarea: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
        'availableLists': _lists.where((l) => l != 'Hoy').toList(),
      },
    );
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty && _userId != null) {
                  try {
                    await _addTaskList(controller.text);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al crear lista: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTaskList(String listName) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('taskLists')
        .doc(listName)
        .set({'createdAt': FieldValue.serverTimestamp()});

    setState(() {
      _lists.add(listName);
      _selectedList = listName;
    });
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty &&
                    controller.text != currentName &&
                    _userId != null) {
                  try {
                    await _renameTaskList(currentName, controller.text);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al renombrar: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Renombrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameTaskList(String oldName, String newName) async {
    if (_userId == null || oldName == 'Hoy' || oldName == 'Ideas') return;

    // Actualizar el nombre de la lista en taskLists
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('taskLists')
        .doc(oldName)
        .delete();

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('taskLists')
        .doc(newName)
        .set({'createdAt': FieldValue.serverTimestamp()});

    // Actualizar todas las tareas que pertenecen a esta lista
    final batch = _firestore.batch();
    final tasks = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .where('listName', isEqualTo: oldName)
        .get();

    for (var task in tasks.docs) {
      batch.update(task.reference, {'listName': newName});
    }

    await batch.commit();

    setState(() {
      final index = _lists.indexOf(oldName);
      _lists[index] = newName;
      _selectedList = newName;
    });
  }

  Future<void> _deleteList(String listName) async {
    if (listName == 'Ideas' || listName == 'Hoy' || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar esta lista'),
        ),
      );
      return;
    }

    // Verificar si hay tareas en esta lista
    final tasks = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .where('listName', isEqualTo: listName)
        .get();

    if (tasks.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar una lista con tareas'),
        ),
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('taskLists')
          .doc(listName)
          .delete();

      setState(() {
        _lists.remove(listName);
        if (_selectedList == listName) {
          _selectedList = 'Ideas';
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar lista: $e')),
      );
    }
  }

  Future<void> _moveTaskToList(String taskId, String newList) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'listName': newList,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Selector de listas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 60,
            color: Theme.of(context).appBarTheme.backgroundColor,
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
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 18, 
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('Nueva lista',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary)),
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
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _selectedList == listName
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
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
                              children: [
                                Icon(Icons.edit, size: 20,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                                const SizedBox(width: 8),
                                const Text('Renombrar lista'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20,
                                    color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Text('Eliminar lista',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTasksForListStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Error en stream de tareas: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 50, 
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                const Text('Error al cargar tareas'),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list, size: 50, 
                    color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                Text(
                  'No hay tareas en "$_selectedList"',
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
              ],
            ),
          );
        }

        final tasks = snapshot.data!.docs;
        final pendingTasks =
            tasks.where((doc) => !(doc['isCompleted'] ?? false)).toList();
        final completedTasks =
            tasks.where((doc) => doc['isCompleted'] ?? false).toList();

        return ListView(
          padding: const EdgeInsets.all(6),
          children: [
            ...pendingTasks.map((doc) => _buildTaskItem(doc)).toList(),
            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    setState(() => _showCompletedTasks = !_showCompletedTasks),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tareas Completadas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Icon(_showCompletedTasks
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_showCompletedTasks)
                ...completedTasks.map((doc) => _buildTaskItem(doc)).toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTodayTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTodayTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Error en stream de tareas de hoy: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 50,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                const Text('Error al cargar tareas'),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.today, size: 50,
                    color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                const Text(
                  'No hay tareas pendientes para hoy',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) => _buildTaskItem(snapshot.data!.docs[index]),
        );
      },
    );
  }

  Widget _buildTaskItem(DocumentSnapshot doc) {
    final task = doc.data() as Map<String, dynamic>;
    final isCompleted = task['isCompleted'] ?? false;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) => _toggleTaskCompletion(doc.id, !isCompleted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Theme.of(context).disabledColor;
          }),
        ),
        title: Text(
          task['title'] ?? 'Sin título',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task['description']?.toString().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  task['description'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ),
            if (task['dueTime'] != null && task['dueDate'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16,
                        color: Theme.of(context).disabledColor),
                    const SizedBox(width: 4),
                    Text(
                      '${task['dueTime']} - ${task['dueDate']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  const SizedBox(width: 8),
                  const Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'move',
              child: Row(
                children: [
                  Icon(Icons.move_to_inbox, size: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  const SizedBox(width: 8),
                  const Text('Mover a otra lista'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text('Eliminar',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
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
                  'task': {'id': doc.id, ...task},
                  'userId': _userId,
                  'availableLists': _lists,
                },
              );
            } else if (value == 'move') {
              _showMoveTaskDialog(context, doc.id);
            } else if (value == 'delete') {
              _showDeleteConfirmationDialog(context, doc.id);
            }
          },
        ),
      ),
    );
  }

  void _showMoveTaskDialog(BuildContext context, String taskId) {
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

  void _showDeleteConfirmationDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar tarea'),
          content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTask(taskId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}