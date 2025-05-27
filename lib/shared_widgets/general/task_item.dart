import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskItem extends StatelessWidget {
  final String text;
  final Color? textColor;

  const TaskItem({
    Key? key,
    required this.text,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Acceder al tema actual
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor, // Adaptar el color según el tema
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.0,
          fontFamily: GoogleFonts.inter().fontFamily,
          color: textColor ?? theme.textTheme.bodyLarge?.color ?? Colors.black,
        ),
      ),
    );
  }
}
