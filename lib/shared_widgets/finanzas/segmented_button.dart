import 'package:flutter/material.dart';

class CustomSegmentedButton extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final Function(int) onSegmentSelected;

  const CustomSegmentedButton({
    Key? key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 351),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          segments.length,
          (index) => Expanded(
            child: _SegmentButton(
              label: segments[index],
              isSelected: selectedIndex == index,
              isFirstSegment: index == 0,
              isLastSegment: index == segments.length - 1,
              onTap: () => onSegmentSelected(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isFirstSegment;
  final bool isLastSegment;
  final VoidCallback onTap;

  const _SegmentButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.isFirstSegment,
    required this.isLastSegment,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8DEF8) : Colors.white,
                borderRadius: BorderRadius.horizontal(
                  left: isFirstSegment ? const Radius.circular(100) : Radius.zero,
                  right: isLastSegment ? const Radius.circular(100) : Radius.zero,
                ),
                border: Border.all(
                  color: const Color(0xFF79747E),
                  width: 1,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF4A4459) : const Color(0xFF1D1B20),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}