import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDaysOfWeek(),
        _buildWeek(1, 0, 5),
        _buildWeek(2, 6, 12),
        _buildWeek(3, 13, 19, selectedDay: 17),
        _buildWeek(4, 20, 26),
        _buildWeek(5, 27, 31, hasEmptyDays: true),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: days.map((day) => _buildDayHeader(day)).toList(),
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Center(
        child: Text(
          day,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1D1B20),
            letterSpacing: 0.5,
          ),
          semanticsLabel: _getFullDayName(day),
        ),
      ),
    );
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay) {
      case 'S': return shortDay == 'S' ? 'Sunday' : 'Saturday';
      case 'M': return 'Monday';
      case 'T': return 'Tuesday';
      case 'W': return 'Wednesday';
      case 'F': return 'Friday';
      default: return 'Thursday';
    }
  }

  Widget _buildWeek(int weekNumber, int startDay, int endDay, {int? selectedDay, bool hasEmptyDays = false}) {
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      int day = startDay + i;

      if (day > endDay || (hasEmptyDays && i > endDay - startDay)) {
        dayWidgets.add(_buildEmptyDay());
      } else if (day == selectedDay) {
        dayWidgets.add(_buildSelectedDay(day));
      } else if (weekNumber == 1 && day == 5) {
        dayWidgets.add(_buildOutlinedDay(day));
      } else {
        dayWidgets.add(_buildRegularDay(day));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildEmptyDay() {
    return const Expanded(
      child:Padding(
        padding: EdgeInsets.all(4.0),
        child: SizedBox(
          height: 40,
          width: 40,
        ),
      ),
    );
  }

  Widget _buildRegularDay(int day) {
    return Expanded(
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                // Handle day selection
              },
              child: Center(
                child: Text(
                  day.toString(),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                    letterSpacing: 0.5,
                  ),
                  semanticsLabel: 'Day $day',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedDay(int day) {
    return Expanded(
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF65558F),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                // Handle day selection
              },
              child: Center(
                child: Text(
                  day.toString(),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF65558F),
                    letterSpacing: 0.5,
                  ),
                  semanticsLabel: 'Day $day',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDay(int day) {
    return Expanded(
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color(0xFF65558F),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                // Handle day selection
              },
              child: Center(
                child: Text(
                  day.toString(),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                  semanticsLabel: 'Selected day $day',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}