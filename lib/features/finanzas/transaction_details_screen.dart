import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared_widgets/finanzas/transaction_field.dart';
import '../../shared_widgets/finanzas/action_button.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set status bar to be transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Status bar space
          Container(
            height: 44,
            color: Colors.transparent,
          ),

          // Background ellipse
          Positioned(
            top: 33,
            left: 0,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.only(top: 17),
                  child: Center(
                    child: Text(
                      'Detalles de la transacción',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      semanticsLabel: 'Detalles de la transacción heading',
                    ),
                  ),
                ),

                // Transaction fields
                const Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 100),
                          TransactionField(
                            label: 'Cantidad',
                            value: '\$ 3.300 COP',
                          ),
                          SizedBox(height: 47),
                          TransactionField(
                            label: 'Categoría',
                            value: 'Transporte',
                          ),
                          SizedBox(height: 47),
                          TransactionField(
                            label: 'Fecha',
                            value: '2 de marzo de 2025',
                          ),
                          SizedBox(height: 47),
                          TransactionField(
                            label: 'Hora',
                            value: '12:15',
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 93),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            label: 'Editar',
                            icon: Icons.edit,
                            onPressed: () {
                              // Handle edit action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Editar pressed')),
                              );
                            },
                          ),
                          ActionButton(
                            label: 'Eliminar',
                            icon: Icons.delete,
                            onPressed: () {
                              // Handle delete action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Eliminar pressed')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 19),
                      ActionButton(
                        label: 'Volver',
                        icon: Icons.chevron_left,
                        onPressed: () {
                          // Handle back action
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // Home indicator
                Container(
                  height: 34,
                  alignment: Alignment.center,
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
