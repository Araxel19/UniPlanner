import 'package:flutter/material.dart';

/// A reusable widget that displays a labeled transaction field.
///
/// This widget shows a label above a bordered container with text content.
class TransactionField extends StatelessWidget {
  final String label;
  final String value;

  const TransactionField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          semanticsLabel: '$label field',
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCAC4D0)),
          ),
          height: 32,
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF49454F),
              ),
            ),
          ),
        ),
      ],
    );
  }
}