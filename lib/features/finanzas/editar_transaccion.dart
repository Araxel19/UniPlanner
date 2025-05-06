import 'package:flutter/material.dart';
import '../../core/db/firebase_finanzas_helper.dart';

class EditarTransaccion extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditarTransaccion({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<EditarTransaccion> createState() => _EditarTransaccionState();
}

class _EditarTransaccionState extends State<EditarTransaccion> {
  late bool _isExpenseSelected;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late DateTime _selectedDate;
  String? _selectedCategory;
  final FirebaseFinanzasHelper _firebaseHelper = FirebaseFinanzasHelper();

  @override
  void initState() {
    super.initState();
    _isExpenseSelected = widget.transaction['isIncome'] != 1;
    _descriptionController.text = widget.transaction['description'];
    _amountController.text = widget.transaction['amount'].toString();
    _selectedCategory = widget.transaction['category'];

    final dateParts = widget.transaction['date'].toString().split('-');
    final timeParts = widget.transaction['time'].toString().split(':');
    _selectedDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Transacción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                setState(() {
                  _isExpenseSelected = newSelection.first;
                  _selectedCategory = null;
                });
              },
            ),
            const SizedBox(height: 24),
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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                'Comida',
                'Transporte',
                'Compras',
                'Salud',
                'Entretenimiento',
                'Salario',
                'Ventas',
                'Inversiones',
                'Regalos',
                'Préstamos'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),
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
            FilledButton(
              onPressed: _guardarCambios,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos requeridos')),
      );
      return;
    }

    try {
      await _firebaseHelper.updateTransaction(
        transactionId: widget.transaction['id'],
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        category: _selectedCategory!,
        isIncome: !_isExpenseSelected,
        date: _selectedDate,
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }
}
