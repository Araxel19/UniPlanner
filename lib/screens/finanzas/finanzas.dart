import 'package:flutter/material.dart';
import '../../widgets/finanzas/transaction_item.dart';
import '../../widgets/finanzas/segmented_button.dart';
import '../../widgets/bottom_navigation.dart';
import 'agregar_movimientos.dart';
import 'transaction_details_screen.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({Key? key}) : super(key: key);

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  int _selectedSegmentIndex = 0;

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Financial Summary
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Semantics(
                      label:
                          'Financial summary showing total of 2,842,000 pesos',
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mis Finanzas',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              letterSpacing: 0.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Total',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              letterSpacing: 0.1,
                            ),
                          ),
                          Text(
                            '\$ 2.842.000',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Segmented Button
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Center(
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
                ),

                // Transactions List
                Container(
                  margin: const EdgeInsets.only(top: 22),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 334),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child:const Column(
                    children: [
                      TransactionItem(
                        date: '02/03/2025',
                        amount: 30000,
                        isIncome: true,
                        category: 'Trabajo',
                        description: 'Diseño UI',
                        icon: Icons.work,
                      ),
                      SizedBox(height: 8),
                      TransactionItem(
                        date: '02/03/2025',
                        amount: 3300,
                        isIncome: false,
                        category: 'Transporte',
                        description: 'Bus',
                        icon: Icons.directions_bus,
                      ),
                      SizedBox(height: 8),
                      TransactionItem(
                        date: '02/03/2025',
                        amount: 3300,
                        isIncome: false,
                        category: 'Transporte',
                        description: 'Bus',
                        icon: Icons.directions_bus,
                      ),
                      SizedBox(height: 8),
                      TransactionItem(
                        date: '01/03/2025',
                        amount: 150000,
                        isIncome: true,
                        category: 'Regalo',
                        description: 'Cumpleaños',
                        icon: Icons.card_giftcard,
                      ),
                      SizedBox(height: 10),
                      TransactionItem(
                        date: '01/03/2025',
                        amount: 148650,
                        isIncome: false,
                        category: 'Servicios',
                        description: 'Agua',
                        icon: Icons.water_drop,
                      ),
                      SizedBox(height: 10),
                      TransactionItem(
                        date: '01/03/2025',
                        amount: 148650,
                        isIncome: false,
                        category: 'Servicios',
                        description: 'Gas',
                        icon: Icons.gas_meter,
                      ),
                      SizedBox(height: 10),
                      TransactionItem(
                        date: '02/03/2025',
                        amount: 30000,
                        isIncome: true,
                        category: 'Trabajo',
                        description: 'Diseño UI',
                        icon: Icons.work,
                      ),
                      SizedBox(height: 10),
                      TransactionItem(
                        date: '25/02/2025',
                        amount: 30000,
                        isIncome: true,
                        category: 'Trabajo',
                        description: 'Diseño Web',
                        icon: Icons.web,
                      ),
                      SizedBox(height: 10),
                      TransactionItem(
                        date: '12/02/2025',
                        amount: 30000,
                        isIncome: true,
                        category: 'Trabajo',
                        description: 'Diseño App',
                        icon: Icons.phone_android,
                      ),
                    ],
                  ),
                ),

                // Add Movement Button
                Padding(
                  padding: const EdgeInsets.only(top: 39),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AgregarMovimientos(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Agregar Movimiento',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A4459),
                          letterSpacing: 0.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        iconColor:const Color(0xFFE8DEF8),
                        minimumSize: const Size(196, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 47),
                  child: BottomNavigation(), // Widget de navegación inferior
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
