import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/sqlite_helper.dart';

class AgregarMovimientos extends StatefulWidget {
  const AgregarMovimientos({Key? key}) : super(key: key);

  @override
  State<AgregarMovimientos> createState() => _AgregarMovimientosState();
}

class _AgregarMovimientosState extends State<AgregarMovimientos> {
  bool _isExpenseSelected = true;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  // Mapa de íconos constantes para las categorías
  final Map<String, IconData> iconMap = {
    'Gasto': Icons.arrow_circle_down, // Mapea el nombre de la categoría a un ícono fijo
    'Ingreso': Icons.arrow_circle_up,
    // Agrega más categorías aquí con sus íconos respectivos
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleExpenseIncome(bool isExpense) {
    setState(() {
      _isExpenseSelected = isExpense;
      _selectedCategory = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = Provider.of<SQLiteHelper>(context);
    final currentUser = Provider.of<Map<String, dynamic>?>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Agregar Movimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de tipo (ingreso/gasto)
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Gasto'),
                  icon: Icon(Icons.arrow_circle_down),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.arrow_circle_up),
                ),
              ],
              selected: <bool>{_isExpenseSelected},
              onSelectionChanged: (Set<bool> newSelection) {
                _toggleExpenseIncome(newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            // Campo de monto
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            // Selector de categoría
            FutureBuilder<List<Map<String, dynamic>>>( 
              future: db.getCategoriesByType(
                isIncome: !_isExpenseSelected,
                userId: currentUser?['id'] ?? 0,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final categories = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Row(
                        children: [
                          Icon(iconMap[category['name']] ?? Icons.help_outline), // Usar el ícono mapeado
                          const SizedBox(width: 8),
                          Text(category['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // Selector de fecha
            OutlinedButton(
              onPressed: _selectDate,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Campo de descripción
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_amountController.text.isEmpty ||
                          _selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor complete todos los campos requeridos'),
                          ),
                        );
                        return;
                      }

                      db.addTransaction(
                        amount: double.parse(_amountController.text),
                        description: _descriptionController.text,
                        category: _selectedCategory!,
                        isIncome: !_isExpenseSelected,
                        date: _selectedDate,
                        userId: currentUser?['id'] ?? 0,
                      );

                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
