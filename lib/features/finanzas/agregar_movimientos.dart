import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/db/sqlite_helper.dart';
import 'package:provider/provider.dart';

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
  Map<String, dynamic>? _selectedCategoryData;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

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
      _selectedCategoryData = null;
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            // Selector de categoría mejorado con dropdown_button2
            FutureBuilder<List<Map<String, dynamic>>>(
              future: db.getCategoriesByType(
                isIncome: !_isExpenseSelected,
                userId: _userId ?? 0,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text('Error al cargar categorías');
                }

                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const Text('No hay categorías disponibles');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categoría', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        value: _selectedCategory,
                        hint: const Text('Seleccione una categoría'),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['name'],
                            child: Row(
                              children: [
                                Icon(
                                  IconData(
                                    category['iconCode'],
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  size: 20,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(category['name']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedCategoryData = categories.firstWhere(
                                (c) => c['name'] == value,
                                orElse: () => {},
                              );
                            });
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          width: MediaQuery.of(context).size.width - 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.cardColor,
                          ),
                          offset: const Offset(0, -5),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all<double>(6),
                            thumbVisibility: MaterialStateProperty.all<bool>(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ],
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
                    onPressed: () async {
                      if (_userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debes iniciar sesión para agregar movimientos'),
                          ),
                        );
                        return;
                      }
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

                      try {
                        await db.addTransaction(
                          amount: double.parse(_amountController.text),
                          description: _descriptionController.text,
                          category: _selectedCategory!,
                          isIncome: !_isExpenseSelected,
                          date: _selectedDate,
                          userId: _userId!,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar: ${e.toString()}'),
                          ),
                        );
                      }
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