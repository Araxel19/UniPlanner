import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';
import '../../core/db/sqlite_helper.dart';
import 'package:intl/intl.dart';

class Calendario extends StatefulWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late final ValueNotifier<List<dynamic>> _selectedItems;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isOptionsVisible = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedItems = ValueNotifier<List<dynamic>>([]);
    _loadUserId();
    _loadItemsForDay(_selectedDay);
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  @override
  void dispose() {
    _selectedItems.dispose();
    super.dispose();
  }

  Future<void> _loadItemsForDay(DateTime day) async {
    if (_userId == null) {
      _selectedItems.value = [];
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(day);
    final dbHelper = SQLiteHelper();

    // Obtener eventos del usuario
    final eventsData =
        await dbHelper.getEventsForDay(formattedDate, userId: _userId);
    final userEvents = eventsData.map((e) => Event.fromMap(e)).toList();

    // Obtener tareas del usuario
    final tasksData =
        await dbHelper.getTasksForDay(formattedDate, userId: _userId);
    final userTasks = tasksData.map((t) => Task.fromMap(t)).toList();

    // Combinar y ordenar
    _selectedItems.value = [...userTasks, ...userEvents];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = Theme.of(context).colorScheme.background;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final iconColor = Theme.of(context).iconTheme.color ?? textColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendario Académico',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: scaffoldColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
      ),
      backgroundColor: scaffoldColor,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const BottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            // Calendario más compacto
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2B2930) : const Color(0xFFECE6F0),
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDatePickerHeader(textColor),
                  _buildMonthSelector(textColor),
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _loadItemsForDay(selectedDay);
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFB69DF8)
                            : const Color(0xFF6750A4),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3E3A47)
                            : const Color(0xFFD0BCFF),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                          color: textColor, fontSize: 12), // Texto más pequeño
                      weekendTextStyle: TextStyle(color: textColor),
                      outsideDaysVisible: false,
                    ),
                    headerVisible: false,
                    daysOfWeekHeight: 28, // Altura reducida
                    rowHeight: 36, // Altura reducida
                  ),
                ],
              ),
            ),

            // Divisor
            Divider(
              height: 1,
              thickness: 1,
              color: textColor.withOpacity(0.1),
              indent: 16,
              endIndent: 16,
            ),

            // Lista de eventos/tareas organizada por hora
            Expanded(
              child: _buildTimedEventsList(textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimedEventsList(Color textColor) {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _selectedItems,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No hay actividades para este día',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
              ),
            ),
          );
        }

        // Agrupar items por hora
        final itemsByHour = <String, List<dynamic>>{};

        for (var item in items) {
          String hour = '';
          if (item is Event) {
            hour = item.startTime.split(':').first.padLeft(2, '0');
          } else if (item is Task) {
            hour = item.dueTime.split(':').first.padLeft(2, '0');
          }

          if (!itemsByHour.containsKey(hour)) {
            itemsByHour[hour] = [];
          }
          itemsByHour[hour]!.add(item);
        }

        // Ordenar las horas
        final sortedHours = itemsByHour.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: sortedHours.length,
          itemBuilder: (context, index) {
            final hour = sortedHours[index];
            final hourItems = itemsByHour[hour]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hora con línea
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '$hour:00',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          height: 1,
                          color: textColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Items para esta hora
                ...hourItems.map((item) {
                  if (item is Task) {
                    return _buildTaskItem(item, textColor);
                  } else if (item is Event) {
                    return _buildEventItem(item, textColor);
                  }
                  return const SizedBox.shrink();
                }),

                // Espaciado entre grupos de hora
                if (index < sortedHours.length - 1) const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToAddEvent() async {
    if (_userId == null) {
      _showLoginRequired();
      return;
    }

    await AppRoutes.push(
      context,
      AppRoutes.addEvent,
      arguments: _userId,
    );

    // Recargar items después de volver
    _loadItemsForDay(_selectedDay);
  }

  Future<void> _navigateToAddTask() async {
    if (_userId == null) {
      _showLoginRequired();
      return;
    }

    await AppRoutes.push(
      context,
      AppRoutes.taskInput,
      arguments: _userId,
    );

    // Recargar items después de volver
    _loadItemsForDay(_selectedDay);
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debes iniciar sesión para agregar eventos'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTaskItem(Task task, Color textColor) {
    return GestureDetector(
      onTap: () => _showTaskDetails(task, context),
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: task.isCompleted ? Colors.green : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (task.dueTime.isNotEmpty)
                    Text(
                      task.dueTime,
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 12,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(Event event, Color textColor) {
    return GestureDetector(
      onTap: () => _showEventDetails(event, context),
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
            Text(
              '${event.startTime} - ${event.endTime}',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Event event, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: primaryColor,
                    onPressed: () => _editEvent(event),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección de detalles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                        Icons.description, event.description, onSurfaceColor),
                    const Divider(height: 24),
                    _buildDetailRow(
                        Icons.calendar_today, event.date, onSurfaceColor),
                    const Divider(height: 24),
                    _buildDetailRow(
                        Icons.access_time,
                        '${event.startTime} - ${event.endTime}',
                        onSurfaceColor),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                      onPressed: () => _deleteEvent(event.id, context),
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _editEvent(event),
                    child: const Text('Editar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(Task task, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Improved header with better checkbox
              Row(
                children: [
                  // New circular checkbox design
                  GestureDetector(
                    onTap: () => _toggleTaskCompletion(task, context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted ? Colors.green : primaryColor,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: primaryColor,
                    onPressed: () => _editTask(task),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details section remains the same
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.description,
                      task.description,
                      onSurfaceColor,
                      isCompleted: task.isCompleted,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.calendar_today,
                      task.dueDate,
                      onSurfaceColor,
                      isCompleted: task.isCompleted,
                    ),
                    if (task.dueTime.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.access_time,
                        task.dueTime,
                        onSurfaceColor,
                        isCompleted: task.isCompleted,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _deleteTask(task.id, context),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _editTask(task),
                    child: const Text('Editar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTaskCompletion(Task task, BuildContext context) async {
    final dbHelper = SQLiteHelper();
    try {
      await dbHelper.updateTaskCompletion(task.id, !task.isCompleted);
      Navigator.pop(context);
      _loadItemsForDay(_selectedDay);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _deleteTask(int taskId, BuildContext context) async {
    final dbHelper = SQLiteHelper();
    try {
      await dbHelper.deleteTask(taskId);
      Navigator.pop(context);
      _loadItemsForDay(_selectedDay);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _deleteEvent(int eventId, BuildContext context) async {
    final dbHelper = SQLiteHelper();
    try {
      await dbHelper.deleteEvent(eventId);
      Navigator.pop(context);
      _loadItemsForDay(_selectedDay);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _editEvent(Event event) async {
    Navigator.pop(context); // Cerrar el modal actual
    await AppRoutes.push(
      context,
      AppRoutes.editEvent,
      arguments: {'event': event, 'userId': _userId},
    );
    _loadItemsForDay(_selectedDay);
  }

  Future<void> _editTask(Task task) async {
    Navigator.pop(context); // Cerrar el modal actual
    await AppRoutes.push(
      context,
      AppRoutes.editTask,
      arguments: {'task': task, 'userId': _userId},
    );
    _loadItemsForDay(_selectedDay);
  }

  Widget _buildDetailRow(IconData icon, String text, Color color,
      {bool isCompleted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: color,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerHeader(Color textColor) {
    final formattedDate = DateFormat('EEE, MMM d').format(_selectedDay);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 12.0, 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: textColor.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(Color textColor) {
    final formattedMonth = DateFormat('MMMM yyyy').format(_focusedDay);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 12.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 10.0, 4.0, 10.0),
                child: Row(
                  children: [
                    Text(
                      formattedMonth,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, size: 18, color: textColor),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left, color: textColor),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_right, color: textColor),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOptionsVisible) ...[
          Transform.translate(
            offset: const Offset(
                0, 0), // Ajusta este valor si necesitas mover verticalmente
            child: _buildOptionButton(
              "Agregar Evento",
              _navigateToAddEvent,
            ),
          ),
          const SizedBox(height: 8),
          Transform.translate(
            offset: const Offset(
                0, 0), // Ajusta este valor si necesitas mover verticalmente
            child: _buildOptionButton(
              "Agregar Tarea",
              _navigateToAddTask,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          backgroundColor: const Color(0xFF6750A4),
          elevation: 6,
          child: Icon(
            _isOptionsVisible ? Icons.close : Icons.add,
            color: Colors.white,
          ),
          onPressed: () =>
              setState(() => _isOptionsVisible = !_isOptionsVisible),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 0), // Eliminamos el margen derecho
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF6750A4),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            onTap();
            setState(() => _isOptionsVisible = false);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label.contains('Evento') ? Icons.event : Icons.task,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Event {
  final int id;
  final String title;
  final String description;
  final String date;
  final String startTime;
  final String endTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}

class Task {
  final int id;
  final String title;
  final String description;
  final String dueDate;
  final String dueTime;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDate: map['dueDate'],
      dueTime: map['dueTime'] ?? '',
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
