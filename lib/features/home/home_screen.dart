import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared_widgets/general/task_item.dart';
import 'balance_card.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import '../../shared_widgets/general/app_routes.dart';
import 'dart:math';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  List<String> todayTasks = ['Taller PNL', 'Trabajo atena', 'Ejercicio redes'];
  List<Map<String, String>> expenses = [
    {'name': 'Pasajes', 'amount': '10.000'},
    {'name': 'Libro Inglés', 'amount': '80.000'},
  ];

  String motivationalQuote = '';
  String quoteAuthor = '';
  bool _isLoadingQuote = true;
  bool _showLocalQuote = true;
  Timer? _quoteTimer;

  // Frases de respaldo en español con autores
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
    _initializeQuote();
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('username') ?? 'Usuario';
    final firstName =
        fullName.split(' ').first; // Obtiene solo el primer nombre

    setState(() {
      _userName = firstName.toUpperCase(); // Convierte a mayúsculas
    });
  }

  void _initializeQuote() {
    // Mostrar una frase local inmediatamente
    final randomQuote = _getRandomBackupQuote();
    setState(() {
      motivationalQuote = randomQuote['quote']!;
      quoteAuthor = randomQuote['author']!;
      _showLocalQuote = true;
    });

    // Iniciar temporizador para cargar de API después de 10 segundos
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

    // Si falla, mantener la frase local que ya mostramos
    setState(() {
      _isLoadingQuote = false;
    });
  }

  Map<String, String> _getRandomBackupQuote() {
    final random = Random();
    return _backupQuotes[random.nextInt(_backupQuotes.length)];
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  double _calculateFontSize(String text) {
    const int baseLength = 100;
    const double baseSize = 16.0;
    const double minSize = 12.0;

    if (text.length <= baseLength) return baseSize;

    double calculatedSize = baseSize - (text.length - baseLength) / 30;
    return calculatedSize.clamp(minSize, baseSize);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quoteFontSize = _calculateFontSize(motivationalQuote);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con nombre y menú
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'BIENVENIDO $_userName 😊',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: GoogleFonts.inter().fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8), // Espacio entre texto y botón
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle, size: 41),
                    onSelected: (value) {
                      if (value == 'config') {
                        Navigator.pushNamed(context, AppRoutes.configuracion);
                      } else if (value == 'logout') {
                        _logout(context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'config',
                          child: Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 12),
                              Text('Configuración'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Cerrar sesión'),
                            ],
                          ),
                        ),
                      ];
                    },
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
                    // Frase motivacional
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

                    // Resto del contenido...
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(24.0),
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Hoy 📅',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ...todayTasks.map((task) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: TaskItem(
                                  text: '✅ $task',
                                  textColor: theme.textTheme.bodyLarge?.color,
                                ),
                              )),
                        ],
                      ),
                    ),

                    BalanceCard(
                      balance: '300.000',
                      expenses: expenses,
                    ),
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
