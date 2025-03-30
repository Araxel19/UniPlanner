import 'package:flutter/material.dart';
import '../../utils/constants.dart';

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

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleExpenseIncome(bool isExpense) {
    setState(() {
      _isExpenseSelected = isExpense;
    });
  }

  void _selectDate() async {
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(left: 21),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 54,
                      color: Colors.blue[800],
                    ),
                  ),
                ),

                // Botón segmentado
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 70),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 207,
                    height: 48,
                    child: Row(
                      children: [
                        // Gastos
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleExpenseIncome(true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isExpenseSelected
                                    ? AppColors.purple
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  bottomLeft: Radius.circular(100),
                                ),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_circle_down,
                                      color: _isExpenseSelected
                                          ? Colors.white
                                          : AppColors.textMedium,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'GASTOS',
                                      style: AppTextStyles.button.copyWith(
                                        color: _isExpenseSelected
                                            ? Colors.white
                                            : AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Ingresos
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleExpenseIncome(false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isExpenseSelected
                                    ? AppColors.purple
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(100),
                                  bottomRight: Radius.circular(100),
                                ),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_circle_up,
                                      color: !_isExpenseSelected
                                          ? Colors.white
                                          : AppColors.textDark,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'INGRESOS',
                                      style: AppTextStyles.button.copyWith(
                                        color: !_isExpenseSelected
                                            ? Colors.white
                                            : AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Monto
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.currency_exchange, size: 18),
                        SizedBox(width: 8),
                        Text('20000 COP', style: AppTextStyles.label),
                      ],
                    ),
                  ),
                ),

                // Categorías
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Text('CATEGORÍAS', style: AppTextStyles.sectionTitle),
                ),

                // Íconos de categorías
                Container(
                  margin: const EdgeInsets.only(top: 29),
                  width: 304,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryButton(Icons.fastfood),
                      _buildCategoryButton(Icons.directions_car),
                      _buildCategoryButton(Icons.shopping_cart),
                      _buildCategoryButton(Icons.health_and_safety),
                      _buildCategoryButton(Icons.sports_esports),
                    ],
                  ),
                ),

                // Botón añadir categoría
                Container(
                  margin: const EdgeInsets.only(top: 23),
                  child: IconButton(
                    icon: const Icon(Icons.add_circle, size: 40),
                    onPressed: () {},
                  ),
                ),

                // Selector de fecha
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    margin: const EdgeInsets.only(top: 23),
                    height: 27,
                    width: 327,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Fecha', style: AppTextStyles.label),
                          SizedBox(width: 22),
                          Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                // Descripción
                const Padding(
                  padding: EdgeInsets.only(top: 22),
                  child: Text('DESCRIPCIÓN', style: AppTextStyles.sectionTitle),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 327,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  margin: const EdgeInsets.only(top: 94),
                  width: 295,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.save,
                          label: 'Guardar',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 53),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.cancel,
                          label: 'Cancelar',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador inferior
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: () {},
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.button),
        ],
      ),
    );
  }
}
