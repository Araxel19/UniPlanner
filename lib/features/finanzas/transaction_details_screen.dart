import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'editar_transaccion.dart';
import '../../core/db/firebase_finanzas_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uniplanner/core/utils/notification_helper.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction['isIncome'] == 1;
    final amount = transaction['amount'] is int 
        ? transaction['amount'].toDouble() 
        : transaction['amount'] as double;

    // Formatear fecha y hora
    final dateTime = _parseDateTime(transaction);
    final formattedDate = dateTime != null 
        ? DateFormat('dd/MM/yyyy').format(dateTime) 
        : 'Fecha no disponible';
    final formattedTime = dateTime != null 
        ? DateFormat('HH:mm').format(dateTime) 
        : 'Hora no disponible';

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
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColorLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (transaction['description'] != null && 
                              transaction['description'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                transaction['description'],
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          _buildDetailRow(
                            context,
                            'Categoría',
                            transaction['category'] ?? 'Sin categoría',
                            Icons.category,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            context,
                            'Fecha',
                            formattedDate,
                            Icons.calendar_today,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            context,
                            'Hora',
                            formattedTime,
                            Icons.access_time,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditarTransaccion(transaction: transaction),
                              ),
                            ).then((updated) {
                              if (updated == true) {
                                Navigator.pop(context, true);
                              }
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
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

  DateTime? _parseDateTime(Map<String, dynamic> transaction) {
    try {
      if (transaction['date'] != null) {
        // Intenta parsear la fecha que puede incluir hora
        final dateString = transaction['date'].toString();
        
        // Primero intenta con formato ISO
        if (dateString.contains('T')) {
          return DateTime.parse(dateString);
        }
        
        // Intenta con formato que incluye hora
        if (dateString.contains(' ')) {
          final parts = dateString.split(' ');
          final datePart = parts[0];
          final timePart = parts[1].split('.')[0]; // Remover milisegundos si existen
          return DateFormat('yyyy-MM-dd HH:mm:ss').parse('$datePart $timePart');
        }
        
        // Solo fecha
        return DateFormat('yyyy-MM-dd').parse(dateString);
      }
      return null;
    } catch (e) {
      debugPrint('Error al parsear fecha: $e');
      return null;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFinanzasHelper().deleteTransaction(transaction['id'] as String);

        // Notificación local al eliminar movimiento
        await flutterLocalNotificationsPlugin.show(
          5556,
          'Movimiento eliminado',
          '¡El movimiento se eliminó correctamente!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'finanzas_channel',
              'Movimientos',
              channelDescription: 'Notificaciones de movimientos financieros',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );

        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    final categoryIcons = {
      'Comida': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Compras': Icons.shopping_cart,
      'Salud': Icons.medical_services,
      'Entretenimiento': Icons.sports_esports,
      'Salario': Icons.work,
      'Regalos': Icons.card_giftcard,
      'Educación': Icons.school,
      'Hogar': Icons.home,
      'Viajes': Icons.flight,
    };

    return categoryIcons[category] ?? Icons.attach_money;
  }
}