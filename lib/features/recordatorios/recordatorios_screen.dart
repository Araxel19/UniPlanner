import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';

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
  Map<String, bool> _completedTasksVisibility = {};
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
        _lists = ['Hoy', 'Ideas']
          ..addAll(listsSnapshot.docs.map((doc) => doc.id));

        for (var list in _lists) {
          _completedTasksVisibility[list] = false;
        }
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
      _completedTasksVisibility[listName] = false;
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
      _completedTasksVisibility[newName] =
          _completedTasksVisibility[oldName] ?? false;
      _completedTasksVisibility.remove(oldName);
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
        _completedTasksVisibility.remove(listName);
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
                const Icon(Icons.error, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar tareas',
                  style: TextStyle(color: Colors.grey),
                ),
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
                const Icon(Icons.list, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hay tareas en "$_selectedList"',
                  style: const TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.all(16),
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
                    const Text(
                      'Tareas Completadas',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                const Icon(Icons.error, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar tareas',
                  style: TextStyle(color: Colors.grey),
                ),
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
                const Icon(Icons.today, size: 50, color: Colors.grey),
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
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) =>
              _buildTaskItem(snapshot.data!.docs[index]),
        );
      },
    );
  }

  Widget _buildTaskItem(DocumentSnapshot doc) {
    final task = doc.data() as Map<String, dynamic>;
    final isCompleted = task['isCompleted'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) => _toggleTaskCompletion(doc.id, !isCompleted),
        ),
        title: Text(
          task['title'] ?? 'Sin título',
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
            if (task['dueTime'] != null && task['dueDate'] != null)
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
                  'task': {'id': doc.id, ...task},
                  'userId': _userId,
                  'availableLists': _lists,
                },
              );
            } else if (value == 'move') {
              _showMoveTaskDialog(context, doc.id);
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
}
