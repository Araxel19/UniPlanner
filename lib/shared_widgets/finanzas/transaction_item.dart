import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String date;
  final double amount;
  final bool isIncome;
  final String category;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const TransactionItem({
    Key? key,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.description,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedAmount = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final String transactionText =
        '$date ${isIncome ? '↑' : '↓'} \$$formattedAmount | $category | $description';

    return Semantics(
        label: isIncome
            ? 'Income transaction: $transactionText'
            : 'Expense transaction: $transactionText',
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isIncome ? const Color(0xFFDBFFBB) : const Color(0xFFFFD2D3),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: Colors.black.withValues(),
                  blurRadius: 3,
                  offset:const Offset(0, 1),
                  spreadRadius: 1,
                ),
              ],
              border:
                  isIncome ? Border.all(color: Colors.black, width: 1) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Transaction detail functionality
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          transactionText,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF49454F),
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, size: 18, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
