import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final List<Map<String, String>> expenses;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFBDD8F8),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Column(
        children: [
          Text(
            '💵Saldo disponible: \$$balance',
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
              children: [
                const TextSpan(text: '📉Gastos Recientes:'),
                const TextSpan(text: '\n'),
                ...expenses.map((expense) =>
                  TextSpan(
                    text: '-${expense['name']}: \$${expense['amount']}\n',
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}