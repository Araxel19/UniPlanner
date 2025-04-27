import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/sqlite_helper.dart';
import 'agregar_movimientos.dart';
import 'transaction_details_screen.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({Key? key}) : super(key: key);

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  int _selectedSegmentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  String _currentPeriod = 'Mes';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = Provider.of<SQLiteHelper>(context);
    final currentUser = Provider.of<Map<String, dynamic>?>(context); // Asume que tienes un provider para el usuario

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal con scroll
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Stream.fromFuture(db.getTransactionsByPeriod(
                  period: _currentPeriod,
                  userId: currentUser?['id'] ?? 0,
                )),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar transacciones'));
                  }

                  final transactions = snapshot.data ?? [];
                  final balance = transactions.fold<double>(0, (sum, t) {
                    final amount = t['amount'] as double;
                    return t['isIncome'] == 1 ? sum + amount : sum - amount;
                  });

                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          // Resumen financiero
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Mis Finanzas',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Balance Total',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                Text(
                                  '${balance >= 0 ? '+' : ''}\$${balance.toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: balance >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Selector de periodo
                          Center(
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
                                setState(() {
                                  _currentPeriod = newSelection.first;
                                });
                              },
                              style: SegmentedButton.styleFrom(
                                backgroundColor: theme.cardColor,
                                selectedBackgroundColor: theme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Lista de transacciones
                          Container(
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: transactions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'No hay transacciones registradas',
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: transactions.length,
                                      itemBuilder: (context, index) {
                                        final transaction = transactions[index];
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                _getIconForCategory(
                                                    transaction['category']),
                                                color: transaction['isIncome'] == 1
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              title: Text(
                                                transaction['description'],
                                                style:
                                                    theme.textTheme.bodyLarge,
                                              ),
                                              subtitle: Text(
                                                transaction['category'],
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                              trailing: Text(
                                                '${transaction['isIncome'] == 1 ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
                                                style: theme.textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                  color: transaction['isIncome'] == 1
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TransactionDetailsScreen(
                                                          transaction: transaction,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (index <
                                                transactions.length - 1)
                                              Divider(
                                                  height: 1,
                                                  color:
                                                      theme.dividerColor),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          // Botón para agregar movimiento
                          Center(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AgregarMovimientos(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Movimiento'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Barra de navegación inferior
            NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.credit_card),
                  label: 'Tarjetas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart),
                  label: 'Estadísticas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (index) {
                // Navegar a otras pantallas según el índice
              },
            ),
          ],
        ),
      ),
    );
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