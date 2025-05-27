import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:uniplanner/core/utils/google_token_helper.dart';
import 'package:uniplanner/providers/GoogleAuthProvider.dart' as my_auth;
import 'package:uniplanner/services/google_calendar_service.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Calendario extends StatefulWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> with TickerProviderStateMixin {
  late final ValueNotifier<List<dynamic>> _selectedItems;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isOptionsVisible = false;
  bool _isLoading = false;
  String? _userId;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _tasksSubscription;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _googleTokenLoaded = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedItems = ValueNotifier<List<dynamic>>([]);

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadUserId().then((_) {
      _loadItemsForDay(_selectedDay);
    });

    // Inicialización básica (si no la tienes en otro lado)
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _tasksSubscription?.cancel();
    _selectedItems.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_googleTokenLoaded) {
      _googleTokenLoaded = true;
      _restoreGoogleToken();
    }
  }

  Future<void> _restoreGoogleToken() async {
    final token = await loadGoogleAccessToken();
    if (token != null) {
      Provider.of<my_auth.GoogleAuthProvider>(context, listen: false)
          .setAccessToken(token);
    }
  }

  Future<void> _loadUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() {
        _userId = user.uid;
      });
      if (mounted) {
        await _loadItemsForDay(_selectedDay);
      }
    }
  }

  Future<void> _loadItemsForDay(DateTime day) async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        _selectedItems.value = [];
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);

      // Cancelar suscripciones anteriores
      _eventsSubscription?.cancel();
      _tasksSubscription?.cancel();

      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .where('date', isEqualTo: formattedDate)
          .get();

      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('dueDate', isEqualTo: formattedDate)
          .get();

      if (!mounted) return;

      final eventsData = eventsSnapshot.docs.map((doc) {
        return Event.fromMap({...doc.data(), 'id': doc.id});
      }).toList();

      final tasksData = tasksSnapshot.docs.map((doc) {
        return Task.fromMap({...doc.data(), 'id': doc.id});
      }).toList();

      if (mounted) {
        _selectedItems.value = [...tasksData, ...eventsData];
      }

      // --- AGREGA ESTA LÍNEA ---
      await _loadGoogleCalendarEvents(context, day);

    } catch (e) {
      debugPrint('Error loading items: $e');
      if (mounted) {
        _selectedItems.value = [];
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadGoogleCalendarEvents(BuildContext context, DateTime day) async {
    // Guarda el accessToken al inicio, antes de cualquier await
    final accessToken = Provider.of<my_auth.GoogleAuthProvider>(context, listen: false).accessToken;
    if (accessToken == null) return; // No hay token

    try {
      final googleEvents = await fetchGoogleCalendarEvents(accessToken);
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);

      // Filtra los eventos del día seleccionado
      final eventsForDay = googleEvents.where((e) {
        final dt = e.start?.dateTime ?? e.start?.date;
        return dt != null && DateFormat('yyyy-MM-dd').format(dt.toLocal()) == formattedDate;
      }).toList();

      // Mapea a tu modelo Event
      final eventModels = eventsForDay.map((e) => Event(
        id: e.id ?? '',
        title: e.summary ?? 'Sin título',
        description: e.description ?? '',
        date: DateFormat('yyyy-MM-dd').format((e.start?.dateTime ?? e.start?.date)!.toLocal()),
        startTime: e.start?.dateTime != null
            ? DateFormat('HH:mm').format(e.start!.dateTime!.toLocal())
            : '',
        endTime: e.end?.dateTime != null
            ? DateFormat('HH:mm').format(e.end!.dateTime!.toLocal())
            : '',
      )).toList();

      // Añade a tu lista de items
      if (mounted) {
        setState(() {
          _selectedItems.value = [..._selectedItems.value, ...eventModels];
        });
      }
    } catch (e) {
      debugPrint('Error cargando eventos de Google Calendar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final iconColor = theme.iconTheme.color ?? textColor;
    final primaryColor = theme.colorScheme.primary;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
            tooltip: _calendarFormat == CalendarFormat.month
                ? 'Vista semanal'
                : 'Vista mensual',
          ),
        ],
      ),
      backgroundColor: scaffoldColor,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const BottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            // Calendario mejorado
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
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
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3E3A47)
                            : primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle:
                          TextStyle(color: textColor, fontSize: 12),
                      weekendTextStyle: TextStyle(color: textColor),
                      outsideDaysVisible: false,
                      markerDecoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersAutoAligned: false,
                    ),
                    headerVisible: false,
                    daysOfWeekHeight: 28,
                    rowHeight: 36,
                    eventLoader: (day) =>
                        [], // Puedes implementar esto para mostrar eventos en el calendario
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _userId == null
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequired();
      return;
    }

    await AppRoutes.push(
      context,
      AppRoutes.addEvent,
      arguments: user.uid,
    );

    if (mounted) {
      await _loadItemsForDay(_selectedDay);
    }
  }

  Future<void> _navigateToAddTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequired();
      return;
    }

    await AppRoutes.push(
      context,
      AppRoutes.taskInput,
      arguments: user.uid, // Usar el UID de Firebase directamente
    );

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
      onTap: () =>
          _showTaskDetails(task, context), // Mostrar detalles al tocar la tarea
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? Colors.green.withOpacity(0.05)
              : Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox interactivo - Ahora con feedback de toque
            GestureDetector(
              onTap: () async {
                await _toggleTaskCompletion(task, context);
              },
              behavior: HitTestBehavior
                  .opaque, // Asegura que toda el área sea tappable
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: ValueKey<bool>(task.isCompleted),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? Colors.green.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? Colors.green : Colors.blue,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: task.isCompleted
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.green)
                          : null,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Contenido de la tarea
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

            // Indicador de que es clickeable (opcional)
            Icon(
              Icons.chevron_right,
              color: textColor.withOpacity(0.3),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[100];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con degradado
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.8),
                      primaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.white, size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _editEvent(event),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección de detalles
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDetailCardRow(
                            icon: Icons.description,
                            title: 'Descripción',
                            content: event.description,
                            color: onSurfaceColor,
                            isCompleted: false,
                          ),
                          const Divider(height: 24),
                          _buildDetailCardRow(
                            icon: Icons.calendar_today,
                            title: 'Fecha',
                            content: event.date,
                            color: onSurfaceColor,
                            isCompleted: false,
                          ),
                          const Divider(height: 24),
                          _buildDetailCardRow(
                            icon: Icons.access_time,
                            title: 'Horario',
                            content: '${event.startTime} - ${event.endTime}',
                            color: onSurfaceColor,
                            isCompleted: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _deleteEvent(event.id, context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Eliminar'),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cerrar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _editEvent(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Editar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
  }

  void _showTaskDetails(Task task, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[100];
    const successColor = Colors.green;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con estado de completado
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      task.isCompleted
                          ? successColor.withOpacity(0.8)
                          : primaryColor.withOpacity(0.8),
                      task.isCompleted ? successColor : primaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleTaskCompletion(task, context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted
                              ? Colors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? Icon(Icons.check, size: 20, color: successColor)
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
                          color: Colors.white,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _editTask(task),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección de detalles
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDetailCardRow(
                            icon: Icons.description,
                            title: 'Descripción',
                            content: task.description,
                            color: onSurfaceColor,
                            isCompleted: task.isCompleted,
                          ),
                          const Divider(height: 24),
                          _buildDetailCardRow(
                            icon: Icons.calendar_today,
                            title: 'Fecha de entrega',
                            content: task.dueDate,
                            color: onSurfaceColor,
                            isCompleted: task.isCompleted,
                          ),
                          if (task.dueTime.isNotEmpty) ...[
                            const Divider(height: 24),
                            _buildDetailCardRow(
                              icon: Icons.access_time,
                              title: 'Hora límite',
                              content: task.dueTime,
                              color: onSurfaceColor,
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
                        TextButton(
                          onPressed: () => _deleteTask(task.id, context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Eliminar'),
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cerrar'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _editTask(task),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Editar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
  }

  Future<void> _toggleTaskCompletion(Task task, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .update({
        'isCompleted': !task.isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar localmente
      setState(() {
        _selectedItems.value = _selectedItems.value.map((item) {
          if (item is Task && item.id == task.id) {
            return Task(
              id: item.id,
              title: item.title,
              description: item.description,
              dueDate: item.dueDate,
              dueTime: item.dueTime,
              isCompleted: !item.isCompleted,
              listName: item.listName,
            );
          }
          return item;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _deleteTask(String taskId, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();

          await flutterLocalNotificationsPlugin.show(
        4444,
        'Tarea eliminada',
        '¡La tarea se eliminó correctamente!',
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

      Navigator.pop(context);
      _loadItemsForDay(_selectedDay);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _deleteEvent(String eventId, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(eventId)
          .delete();

      // Notificación local después de eliminar el evento
      await flutterLocalNotificationsPlugin.show(
        1111,
        'Evento eliminado',
        '¡El evento se eliminó correctamente!',
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

      Navigator.pop(context);
      _loadItemsForDay(_selectedDay);
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
    Navigator.pop(context);
    await AppRoutes.push(
      context,
      AppRoutes.editTask,
      arguments: {
        'task': {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'dueDate': task.dueDate,
          'dueTime': task.dueTime,
          'isCompleted': task.isCompleted,
          'listName': task.listName, // Pasar el listName como parte del Map
        },
        'userId': _userId
      },
    );
    _loadItemsForDay(_selectedDay);
  }

  Widget _buildDetailCardRow({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: color.withOpacity(0.8)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
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
          FadeTransition(
            opacity: _fabAnimation,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: _buildOptionButton(
                "Agregar Evento",
                _navigateToAddEvent,
                Icons.event,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _fabAnimation,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: _buildOptionButton(
                "Agregar Tarea",
                _navigateToAddTask,
                Icons.task,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          backgroundColor: const Color(0xFF6750A4),
          elevation: 6,
          child: AnimatedIcon(
            icon: AnimatedIcons.add_event,
            progress: _fabAnimationController,
          ),
          onPressed: () {
            setState(() => _isOptionsVisible = !_isOptionsVisible);
            if (_isOptionsVisible) {
              _fabAnimationController.forward();
            } else {
              _fabAnimationController.reverse();
            }
          },
        ),
      ],
    );
  }

  Widget _buildOptionButton(String label, VoidCallback onTap, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          onTap();
          setState(() => _isOptionsVisible = false);
          _fabAnimationController.reverse();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
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
    );
  }
}

class Event {
  final String id; // Cambiado de int a String
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
      id: map['id'] ?? '', // Firestore usa IDs como strings
      title: map['title'],
      description: map['description'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}

class Task {
  final String id; // Cambiado de int a String
  final String title;
  final String description;
  final String dueDate;
  final String dueTime;
  final bool isCompleted;
  final String listName;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.isCompleted,
    this.listName = 'Ideas',
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'],
      description: map['description'] ?? '',
      dueDate: map['dueDate'],
      dueTime: map['dueTime'] ?? '',
      isCompleted: map['isCompleted'] ?? false, // Cambiado de 1/0 a bool
      listName: map['listName'] ?? 'Ideas',
    );
  }
}
