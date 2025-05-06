import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'editar_transaccion.dart';
import '../../core/db/firebase_finanzas_helper.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction['isIncome'] == 1;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColorLight,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isIncome
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      _getIconForCategory(transaction['category']),
                      size: 30,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isIncome ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction['description'],
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    context,
                    'Categoría',
                    transaction['category'],
                    Icons.category,
                  ),
                  _buildDetailRow(
                    context,
                    'Fecha',
                    '${transaction['date']}',
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    context,
                    'Hora',
                    '${transaction['time']}',
                    Icons.access_time,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditarTransaccion(transaction: transaction),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              Navigator.pop(context,
                                  true); // Refrescar la pantalla anterior
                            }
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar'),
                              content:
                                  const Text('¿Eliminar esta transacción?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await FirebaseFinanzasHelper().deleteTransaction(
                                  transaction['id']
                                      as String); // Asegura el tipo String
                              Navigator.pop(context, true);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error al eliminar: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ],
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
