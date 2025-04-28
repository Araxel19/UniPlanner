import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/db/sqlite_helper.dart';
import 'agregar_movimientos.dart';
import 'transaction_details_screen.dart';
import 'editar_transaccion.dart';
import '../../shared_widgets/general/bottom_navigation.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({Key? key}) : super(key: key);

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  final ScrollController _scrollController = ScrollController();
  String _currentPeriod = 'Mes';
  String _transactionFilter = 'Todos';
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      _updateDateRange();
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  void _updateDateRange() {
    switch (_currentPeriod) {
      case 'Día':
        _startDate = _selectedDate;
        _endDate = _selectedDate;
        break;
      case 'Semana':
        _startDate =
            _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case 'Mes':
        _startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        _endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        break;
      case 'Año':
        _startDate = DateTime(_selectedDate.year, 1, 1);
        _endDate = DateTime(_selectedDate.year, 12, 31);
        break;
    }
  }

  void _navigatePeriod(int direction) {
    setState(() {
      switch (_currentPeriod) {
        case 'Día':
          _selectedDate = _selectedDate.add(Duration(days: direction));
          break;
        case 'Semana':
          _selectedDate = _selectedDate.add(Duration(days: 7 * direction));
          break;
        case 'Mes':
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month + direction, 1);
          break;
        case 'Año':
          _selectedDate = DateTime(_selectedDate.year + direction, 1, 1);
          break;
      }
      _updateDateRange();
    });
  }

  void _changePeriodType(String newPeriod) {
    setState(() {
      _currentPeriod = newPeriod;
      _updateDateRange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = Provider.of<SQLiteHelper>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado con balance total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: _userId == null
                  ? const CircularProgressIndicator()
                  : FutureBuilder<double>(
                      future: db.getBalance(_userId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final balance = snapshot.data ?? 0;
                        return Column(
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.textTheme.titleMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${balance >= 0 ? '+' : ''}\$${balance.toStringAsFixed(2)} COL\$',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: balance >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Selector de período
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // Flechas de navegación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _navigatePeriod(-1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getDateRangeText(),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _navigatePeriod(1),
                      ),
                    ],
                  ),

                  // Selector de tipo de período
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'Día',
                          label: Text('Día'),
                        ),
                        ButtonSegment<String>(
                          value: 'Semana',
                          label: Text('Semana'),
                        ),
                        ButtonSegment<String>(
                          value: 'Mes',
                          label: Text('Mes'),
                        ),
                        ButtonSegment<String>(
                          value: 'Año',
                          label: Text('Año'),
                        ),
                      ],
                      selected: <String>{_currentPeriod},
                      onSelectionChanged: (Set<String> newSelection) {
                        _changePeriodType(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Selector de tipo (Ingresos/Gastos/Todos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Gastos',
                    label: Text('Gastos'),
                    icon: Icon(Icons.arrow_circle_down),
                  ),
                  ButtonSegment<String>(
                    value: 'Todos',
                    label: Text('Todos'),
                  ),
                  ButtonSegment<String>(
                    value: 'Ingresos',
                    label: Text('Ingresos'),
                    icon: Icon(Icons.arrow_circle_up),
                  ),
                ],
                selected: <String>{_transactionFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _transactionFilter = newSelection.first;
                  });
                },
              ),
            ),

            // Balance del período con tamaño reducido
            Padding(
              padding: const EdgeInsets.all(12),
              child: _userId == null
                  ? const SizedBox.shrink()
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: db.getTransactionsByPeriod(
                        period: _currentPeriod,
                        userId: _userId!,
                        startDate: _startDate,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        List<Map<String, dynamic>> transactions =
                            snapshot.data ?? [];

                        // Filtrar según selección
                        if (_transactionFilter == 'Ingresos') {
                          transactions = transactions
                              .where((t) => t['isIncome'] == 1)
                              .toList();
                        } else if (_transactionFilter == 'Gastos') {
                          transactions = transactions
                              .where((t) => t['isIncome'] != 1)
                              .toList();
                        }

                        // Calcular total del período
                        final periodTotal = transactions.fold<double>(
                            0, (sum, t) {
                          final amount = t['amount'] as double;
                          return t['isIncome'] == 1 ? sum + amount : sum - amount;
                        });

                        return Column(
                          children: [
                            Text(
                              'Balance del período',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${periodTotal >= 0 ? '+' : ''}\$${periodTotal.toStringAsFixed(2)} COL\$',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color:
                                    periodTotal >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Lista de transacciones
            Expanded(
              child: _userId == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: db.getTransactionsByPeriod(
                        period: _currentPeriod,
                        userId: _userId!,
                        startDate: _startDate,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error al cargar datos'));
                        }

                        List<Map<String, dynamic>> transactions =
                            snapshot.data ?? [];

                        // Filtrar según selección
                        if (_transactionFilter == 'Ingresos') {
                          transactions = transactions
                              .where((t) => t['isIncome'] == 1)
                              .toList();
                        } else if (_transactionFilter == 'Gastos') {
                          transactions = transactions
                              .where((t) => t['isIncome'] != 1)
                              .toList();
                        }

                        return transactions.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay transacciones',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              )
                            : ListView.builder(
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final t = transactions[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: ListTile(
                                      leading: Icon(
                                        _getIconForCategory(t['category']),
                                        color: t['isIncome'] == 1
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      title: Text(t['description']),
                                      subtitle: Text(t['category']),
                                      trailing: Text(
                                        '${t['isIncome'] == 1 ? '+' : '-'}\$${t['amount'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: t['isIncome'] == 1
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionDetailsScreen(
                                                    transaction: t),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debes iniciar sesión para agregar movimientos'),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarMovimientos(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  String _getDateRangeText() {
    final format = DateFormat('dd/MM/yyyy');
    switch (_currentPeriod) {
      case 'Día':
        return format.format(_selectedDate);
      case 'Semana':
        final start = _startDate!;
        final end = _endDate!;
        return '${start.day}/${start.month} - ${end.day}/${end.month}';
      case 'Mes':
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case 'Año':
        return _selectedDate.year.toString();
      default:
        return '';
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Comida':
        return Icons.fastfood;
      case 'Transporte':
        return Icons.directions_car;
      case 'Compras':
        return Icons.shopping_cart;
      case 'Salud':
        return Icons.health_and_safety;
      case 'Entretenimiento':
        return Icons.sports_esports;
      case 'Salario':
        return Icons.work;
      case 'Regalos':
        return Icons.card_giftcard;
      default:
        return Icons.attach_money;
    }
  }
}