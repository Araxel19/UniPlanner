import 'package:flutter/material.dart';
import '../../shared_widgets/finanzas/transaction_item.dart';
import '../../shared_widgets/finanzas/segmented_button.dart';
import '../../shared_widgets/general/bottom_navigation.dart';
import 'agregar_movimientos.dart';
import 'DetalleMovimiento.dart'; // Importa el archivo DetalleMovimiento.dart

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({Key? key}) : super(key: key);

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  int _selectedSegmentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal con scroll
            Expanded(
              child: SingleChildScrollView(
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
                          color: isDarkMode
                              ? theme.cardColor
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Mis Finanzas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              '\$ 2.842.000',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Selector de periodo
                      Center(
                        child: CustomSegmentedButton(
                          segments: const ['Día', 'Semana', 'Mes', 'Año'],
                          selectedIndex: _selectedSegmentIndex,
                          onSegmentSelected: (index) {
                            setState(() {
                              _selectedSegmentIndex = index;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Lista de transacciones con scroll interno
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 400, // Altura máxima para el scroll
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          child: ListView(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              // Cada TransactionItem tiene su propio onTap
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DetalleMovimiento(),
                                    ),
                                  );
                                },
                                child: const TransactionItem(
                                  date: '02/03/2025',
                                  amount: 30000,
                                  isIncome: true,
                                  category: 'Trabajo',
                                  description: 'Diseño UI',
                                  icon: Icons.work,
                                ),
                              ),
                              const Divider(height: 1),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DetalleMovimiento(),
                                    ),
                                  );
                                },
                                child: const TransactionItem(
                                  date: '02/03/2025',
                                  amount: 3300,
                                  isIncome: false,
                                  category: 'Transporte',
                                  description: 'Bus',
                                  icon: Icons.directions_bus,
                                ),
                              ),
                              const Divider(height: 1),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DetalleMovimiento(),
                                    ),
                                  );
                                },
                                child: const TransactionItem(
                                  date: '01/03/2025',
                                  amount: 150000,
                                  isIncome: true,
                                  category: 'Regalo',
                                  description: 'Cumpleaños',
                                  icon: Icons.card_giftcard,
                                ),
                              ),
                              const Divider(height: 1),
                              // Repite esto para cada TransactionItem...
                            ],
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
              ),
            ),
            // Barra de navegación inferior
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
