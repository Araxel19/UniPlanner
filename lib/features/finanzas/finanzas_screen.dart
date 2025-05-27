import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/firebase_finanzas_helper.dart';
import 'agregar_movimientos.dart';
import 'transaction_details_screen.dart';
import '../../shared_widgets/general/bottom_navigation.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({Key? key}) : super(key: key);

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  String _currentPeriod = 'Mes';
  String _transactionFilter = 'Todos';
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  final FirebaseFinanzasHelper _firebaseHelper = FirebaseFinanzasHelper();

  @override
  void initState() {
    super.initState();
    _updateDateRange();
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
              child: FutureBuilder<double>(
                future: _firebaseHelper.getBalance(),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseHelper.getTransactionsStream(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  final transactions = snapshot.data?.docs ?? [];

                  // Filtrar según selección
                  List<DocumentSnapshot> filteredTransactions = transactions;
                  if (_transactionFilter == 'Ingresos') {
                    filteredTransactions = transactions
                        .where((t) =>
                            (t.data() as Map<String, dynamic>)['isIncome'] ==
                            true)
                        .toList();
                  } else if (_transactionFilter == 'Gastos') {
                    filteredTransactions = transactions
                        .where((t) =>
                            (t.data() as Map<String, dynamic>)['isIncome'] !=
                            true)
                        .toList();
                  }

                  // Calcular total del período
                  final periodTotal =
                      filteredTransactions.fold<double>(0, (sum, t) {
                    final data = t.data() as Map<String, dynamic>;
                    final amount = data['amount'] as double;
                    return data['isIncome'] ? sum + amount : sum - amount;
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
                          color: periodTotal >= 0 ? Colors.green : Colors.red,
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseHelper.getTransactionsStream(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar datos'));
                  }

                  final transactions = snapshot.data?.docs ?? [];

                  // Filtrar según selección
                  List<DocumentSnapshot> filteredTransactions = transactions;
                  if (_transactionFilter == 'Ingresos') {
                    filteredTransactions = transactions
                        .where((t) =>
                            (t.data() as Map<String, dynamic>)['isIncome'] ==
                            true)
                        .toList();
                  } else if (_transactionFilter == 'Gastos') {
                    filteredTransactions = transactions
                        .where((t) =>
                            (t.data() as Map<String, dynamic>)['isIncome'] !=
                            true)
                        .toList();
                  }

                  return filteredTransactions.isEmpty
                      ? Center(
                          child: Text(
                            'No hay transacciones',
                            style: theme.textTheme.bodyLarge,
                          ),
                        )
                      : // Reemplaza el ListTile dentro del ListView.builder con este código:
                      ListView.builder(
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final t = filteredTransactions[index];
                            final data = t.data() as Map<String, dynamic>;
                            final hasDescription =
                                data['description'] != null &&
                                    data['description'].toString().isNotEmpty;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: data['isIncome']
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getIconForCategory(data['category']),
                                    color: data['isIncome']
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['category'],
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (hasDescription)
                                      Text(
                                        data['description'],
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .textTheme.bodyMedium?.color
                                              ?.withOpacity(0.7),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${data['isIncome'] ? '+' : '-'}\$${data['amount'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: data['isIncome']
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM').format(
                                          (data['date'] as Timestamp).toDate()),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailsScreen(
                                        transaction: {
                                          'id': t.id,
                                          'amount': data['amount'],
                                          'description': data['description'],
                                          'category': data['category'],
                                          'isIncome': data['isIncome'],
                                          'date': (data['date'] as Timestamp)
                                              .toDate(),
                                        },
                                      ),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarMovimientos(),
            ),
          );
          setState(() {}); // Recarga la pantalla al volver
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
      case 'Ventas':
        return Icons.sell;
      case 'Inversiones':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  }
}
