import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';
import '../../core/db/sqlite_helper.dart';
import 'balance_card.dart';
import 'dart:math';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _selectedEmoji = '👤';
  File? _userImage;
  List<Map<String, dynamic>> todayItems = [];
  List<Map<String, String>> expenses = [
    {'name': 'Pasajes', 'amount': '10.000'},
    {'name': 'Libro Inglés', 'amount': '80.000'},
  ];

  String motivationalQuote = '';
  String quoteAuthor = '';
  bool _isLoadingQuote = true;
  bool _showLocalQuote = true;
  bool _isLoadingTasks = true;
  Timer? _quoteTimer;
  final SQLiteHelper _dbHelper = SQLiteHelper();

  double _currentBalance = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoadingFinances = true;

  final List<Map<String, String>> _backupQuotes = [
    {
      "quote":
          "El éxito es la suma de pequeños esfuerzos repetidos día tras día.",
      "author": "Robert Collier"
    },
    {
      "quote":
          "No importa lo lento que vayas, siempre y cuando no te detengas.",
      "author": "Confucio"
    },
    {
      "quote": "Cada día es una nueva oportunidad para cambiar tu vida.",
      "author": "Anónimo"
    },
    {
      "quote":
          "El único límite para nuestros logros de mañana es nuestras dudas de hoy.",
      "author": "Franklin D. Roosevelt"
    },
    {
      "quote":
          "Tú eres más valiente de lo que crees, más fuerte de lo que pareces y más inteligente de lo que piensas.",
      "author": "A.A. Milne"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserAvatar();
    _initializeQuote();
    _loadTodayItems();
    _loadFinancialData();
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('username') ?? 'Usuario';
    final firstName = fullName.split(' ').first;

    setState(() {
      _userName = firstName.toUpperCase();
    });
  }

  Future<void> _loadUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final emoji = prefs.getString('selectedEmoji');
    final imagePath = prefs.getString('userImage');
    final userId = prefs.getInt('userId');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _userImage = File(imagePath);
      });
    } else if (emoji != null) {
      setState(() {
        _selectedEmoji = emoji;
      });
    }
  }

  Future<void> _loadTodayItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) return;

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    try {
      final items = await _dbHelper.getDayItems(formattedDate);

      // Filtrar tareas completadas
      final filteredItems = items.where((item) {
        if (item['type'] == 'task') {
          return item['isCompleted'] != 1; // Mostrar solo tareas no completadas
        }
        return true; // Mostrar todos los eventos
      }).toList();

      setState(() {
        todayItems = filteredItems;
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() {
        todayItems = [
          {'title': 'Error al cargar pendientes', 'type': 'error'}
        ];
        _isLoadingTasks = false;
      });
    }
  }

  Future<void> _loadFinancialData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _isLoadingFinances = false;
      });
      return;
    }

    try {
      final db = SQLiteHelper();

      // Obtener balance actual
      final balance = await db.getBalance(userId);

      // Obtener transacciones recientes (últimas 3)
      final transactions = await db.getTransactionsByPeriod(
        period: 'Mes',
        userId: userId,
        startDate: DateTime.now(),
      );

      // Filtrar solo las últimas 3 transacciones
      final recentTransactions = transactions.take(3).toList();

      setState(() {
        _currentBalance = balance;
        _recentTransactions = recentTransactions;
        _isLoadingFinances = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFinances = false;
      });
      debugPrint('Error al cargar datos financieros: $e');
    }
  }

  void _initializeQuote() {
    final randomQuote = _getRandomBackupQuote();
    setState(() {
      motivationalQuote = randomQuote['quote']!;
      quoteAuthor = randomQuote['author']!;
      _showLocalQuote = true;
    });

    _quoteTimer = Timer(const Duration(seconds: 10), () {
      _fetchMotivationalQuote();
    });
  }

  Future<void> _fetchMotivationalQuote() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://frasedeldia.azurewebsites.net/api/phrase'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String quote = data['phrase']?.toString().trim() ?? '';
        final String author = data['author']?.toString().trim() ?? 'Anónimo';

        if (quote.isNotEmpty) {
          setState(() {
            motivationalQuote = quote;
            quoteAuthor = author;
            _showLocalQuote = false;
            _isLoadingQuote = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error al obtener frase de API: $e');
    }

    setState(() {
      _isLoadingQuote = false;
    });
  }

  Map<String, String> _getRandomBackupQuote() {
    final random = Random();
    return _backupQuotes[random.nextInt(_backupQuotes.length)];
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final day = now.day;
    final month = now.month;
    final year = now.year;

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return '$day de ${months[month - 1]} de $year';
  }

  String _formatTime(String time) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final dateTime = timeFormat.parse(time);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  void _showItemDetails(Map<String, dynamic> item, BuildContext context) {
    final isEvent = item['type'] == 'event';
    final isTask = item['type'] == 'task';
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;

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
                    item['title'] ?? 'Sin título',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      decoration: isTask && item['isCompleted'] == 1
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (isTask)
                    IconButton(
                      icon: Icon(
                        item['isCompleted'] == 1
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: item['isCompleted'] == 1
                            ? Colors.green
                            : primaryColor,
                      ),
                      onPressed: () async {
                        await _toggleTaskCompletion(item, context);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección de detalles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (item['description'] != null &&
                        item['description'].toString().isNotEmpty)
                      _buildDetailRow(
                        Icons.description,
                        item['description'].toString(),
                        onSurfaceColor,
                      ),
                    const Divider(height: 24),
                    if (isEvent)
                      _buildDetailRow(
                        Icons.calendar_today,
                        item['date'] ?? 'Sin fecha',
                        onSurfaceColor,
                      ),
                    if (isTask)
                      _buildDetailRow(
                        Icons.calendar_today,
                        item['dueDate'] ?? 'Sin fecha',
                        onSurfaceColor,
                      ),
                    const Divider(height: 24),
                    if (isEvent)
                      _buildDetailRow(
                        Icons.access_time,
                        '${_formatTime(item['startTime'])} - ${_formatTime(item['endTime'])}',
                        onSurfaceColor,
                      ),
                    if (isTask && item['dueTime'] != null)
                      _buildDetailRow(
                        Icons.access_time,
                        _formatTime(item['dueTime']),
                        onSurfaceColor,
                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTaskCompletion(
      Map<String, dynamic> task, BuildContext context) async {
    final dbHelper = SQLiteHelper();
    try {
      // Convertimos el valor a booleano
      final isCompleted = task['isCompleted'] == 1;
      await dbHelper.updateTaskCompletion(
          task['id'], !isCompleted // Invertimos el estado actual
          );

      // Actualizamos solo el item modificado
      setState(() {
        final index = todayItems.indexWhere((item) => item['id'] == task['id']);
        if (index != -1) {
          todayItems[index]['isCompleted'] = isCompleted ? 0 : 1;

          // Opcional: Si quieres que las tareas completadas desaparezcan
          todayItems.removeWhere(
              (item) => item['type'] == 'task' && item['isCompleted'] == 1);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Widget _buildTaskItem(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isEvent = item['type'] == 'event';
    final isTask = item['type'] == 'task';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isTask && item['isCompleted'] == 1
            ? Colors.green.withOpacity(0.05)
            : isEvent
                ? Colors.purple.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTask && item['isCompleted'] == 1
              ? Colors.green.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono del tipo con animación
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isTask && item['isCompleted'] == 1
                  ? Colors.green.withOpacity(0.2)
                  : isEvent
                      ? Colors.purple[100]
                      : Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEvent ? Icons.calendar_today : Icons.assignment,
              size: 18,
              color: isTask && item['isCompleted'] == 1
                  ? Colors.green[800]
                  : isEvent
                      ? Colors.purple[800]
                      : Colors.blue[800],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showItemDetails(item, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Sin título',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: isTask && item['isCompleted'] == 1
                          ? TextDecoration.lineThrough
                          : null,
                      color: isTask && item['isCompleted'] == 1
                          ? Colors.grey[600]
                          : null,
                    ),
                  ),
                  if (isEvent &&
                      item['startTime'] != null &&
                      item['endTime'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${_formatTime(item['startTime'])} - ${_formatTime(item['endTime'])}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (isTask && item['isCompleted'] == 1)
                              ? Colors.grey[500]
                              : theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                          decoration: isTask && item['isCompleted'] == 1
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  if (isTask && item['dueTime'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(item['dueTime']),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: item['isCompleted'] == 1
                              ? Colors.grey[500]
                              : theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                          decoration: isTask && item['isCompleted'] == 1
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isTask)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: IconButton(
                key: ValueKey(item['isCompleted']),
                icon: Icon(
                  item['isCompleted'] == 1
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: item['isCompleted'] == 1 ? Colors.green : Colors.blue,
                ),
                onPressed: () => _toggleTaskCompletion(item, context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinanceItem(Map<String, dynamic> transaction) {
    final isIncome = transaction['isIncome'] == 1;
    final amount = transaction['amount'] as double;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isIncome
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncome ? Icons.arrow_circle_up : Icons.arrow_circle_down,
          color: isIncome ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        transaction['category'] ?? 'Sin categoría',
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        transaction['description'] ?? 'Sin descripción',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFinanceSection() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400), // Reducido
      padding: const EdgeInsets.all(12.0), // Menos padding
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0), // Radio más pequeño
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Disponible: ',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${_currentBalance.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _currentBalance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingFinances
              ? const Center(child: CircularProgressIndicator())
              : _recentTransactions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No hay transacciones recientes',
                        style: theme.textTheme.bodySmall,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Últimas transacciones:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 100, // Espacio limitado para el scroll
                          child: SingleChildScrollView(
                            child: Column(
                              children: _recentTransactions
                                  .take(3)
                                  .map((transaction) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _buildFinanceItem(transaction),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.finanzas);
              },
              child: const Text('Ver todas las finanzas'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDate = _getCurrentDate();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con nombre y menú (se mantiene igual)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'BIENVENID@ $_userName 😎',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: GoogleFonts.inter().fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.configuracion);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      child: _userImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _userImage!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Frase motivacional (se mantiene igual)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        key: ValueKey(_showLocalQuote ? 'local' : 'api'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(bottom: 32.0),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.1),
                              blurRadius: 6.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '"$motivationalQuote" ✨',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: GoogleFonts.inter().fontFamily,
                                fontStyle: FontStyle.italic,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '- $quoteAuthor',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sección "Hoy" (se mantiene igual)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pendientes Hoy',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currentDate,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          _isLoadingTasks
                              ? const Center(child: CircularProgressIndicator())
                              : todayItems.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Text(
                                        'No hay pendientes para hoy',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 150,
                                      ),
                                      child: Scrollbar(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: todayItems.length,
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            return _buildTaskItem(
                                                todayItems[index]);
                                          },
                                        ),
                                      ),
                                    ),
                        ],
                      ),
                    ),

                    // Nueva sección de finanzas (después de pendientes)
                    _buildFinanceSection(),
                  ],
                ),
              ),
            ),

            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
// Fin de la clase HomeScreen
