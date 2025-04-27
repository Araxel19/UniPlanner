import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final List<Map<String, String>> expenses;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Column(
        children: [
          Text(
            '💵 Saldo disponible: \$$balance',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Text(
            '📉 Gastos Recientes:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          ...expenses.map((expense) {
            return Text(
              '- ${expense['name']}: \$${expense['amount']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
              textAlign: TextAlign.center,
            );
          }).toList(),
        ],
      ),
    );
  }
}
