import 'package:flutter/material.dart';

class TimeSchedule extends StatelessWidget {
  const TimeSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayHeader(),
            const SizedBox(height: 10),
            _buildTimeSlot("1 a.m"),
            const SizedBox(height: 18),
            _buildTimeSlot("2 a.m"),
            const SizedBox(height: 15),
            _buildTimeSlot("3 a.m"),
            const SizedBox(height: 12),
            _buildTimeSlot("4 a.m"),
            const SizedBox(height: 12),
            _buildTimeSlot("5 a.m"),
            const SizedBox(height: 11),
            _buildTimeSlot("6 a.m"),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildFloatingActionButton(),
        ),
      ],
    );
  }

  Widget _buildDayHeader() {
    return Semantics(
      label: 'Wednesday 5',
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: -0.18,
            height: 1.4,
          ),
          children: [
            TextSpan(text: 'Mié'),
            TextSpan(text: '\n'),
            TextSpan(text: '5'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    return Semantics(
      label: time,
      child: Text(
        time,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: -0.18,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle FAB tap
          },
          child: const Center(
            child: Icon(
              Icons.add,
              size: 24,
              color: Color(0xFF6750A4),
            ),
          ),
        ),
      ),
    );
  }
}