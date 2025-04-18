import 'package:flutter/material.dart';

/// A reusable action button widget with an icon and text.
///
/// This button has a rounded shape and is designed for the transaction details screen.
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8DEF8),
        foregroundColor: const Color(0xFF4A4459),
        elevation: 0,
        padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        minimumSize: const Size(0, 40),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}