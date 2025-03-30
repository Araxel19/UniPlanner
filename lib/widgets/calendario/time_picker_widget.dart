import 'package:flutter/material.dart';

class TimePickerWidget extends StatefulWidget {
  final Function() onCancel;
  final Function(TimeOfDay) onConfirm;

  const TimePickerWidget({
    Key? key,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay _selectedTime;
  bool _isAM = true;
  String _hour = '20';
  String _minute = '00';
  bool _isHourFocused = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFECE6F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Enter time',
              style: TextStyle(
                color: Color(0xFF49454F),
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                height: 1,
              ),
              semanticsLabel: 'Enter time header',
            ),
          ),

          // Time input section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                // Hour & Minute selector
                Expanded(
                  child: Row(
                    children: [
                      // Hour
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isHourFocused = true;
                                });
                              },
                              child: Container(
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _isHourFocused
                                      ? const Color(0xFFEADDFF)
                                      : const Color(0xFFE6E0E9),
                                  border: _isHourFocused
                                      ? Border.all(color: const Color(0xFF65558F), width: 2)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _hour,
                                      style: TextStyle(
                                        color: _isHourFocused
                                            ? const Color(0xFF4F378A)
                                            : const Color(0xFF1D1B20),
                                        fontSize: 45,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                        height: 1,
                                      ),
                                    ),
                                    if (_isHourFocused)
                                      Container(
                                        width: 2,
                                        height: 42,
                                        color: const Color(0xFF65558F),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: Text(
                                'Hour',
                                style: TextStyle(
                                  color: Color(0xFF49454F),
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.4,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Separator
                      const SizedBox(
                        width: 24,
                        child: Center(
                          child: Text(
                            ':',
                            style: TextStyle(
                              color: Color(0xFF1D1B20),
                              fontSize: 57,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Minute
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isHourFocused = false;
                                });
                              },
                              child: Container(
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: !_isHourFocused
                                      ? const Color(0xFFEADDFF)
                                      : const Color(0xFFE6E0E9),
                                  border: !_isHourFocused
                                      ? Border.all(color: const Color(0xFF65558F), width: 2)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _minute,
                                  style: TextStyle(
                                    color: !_isHourFocused
                                        ? const Color(0xFF4F378A)
                                        : const Color(0xFF1D1B20),
                                    fontSize: 45,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: Text(
                                'Minute',
                                style: TextStyle(
                                  color: Color(0xFF49454F),
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.4,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // AM/PM selector
                Container(
                  width: 52,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF79747E), width: 1),
                    color: const Color(0xFFECE6F0),
                  ),
                  child: Column(
                    children: [
                      // AM
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAM = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isAM ? const Color(0xFFFFD8E4) : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                topRight: Radius.circular(7),
                              ),
                              border: const Border(
                                bottom: BorderSide(color: Color(0xFF79747E), width: 1),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'AM',
                              style: TextStyle(
                                color: _isAM ? const Color(0xFF633B48) : const Color(0xFF49454F),
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // PM
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAM = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isAM ? const Color(0xFFFFD8E4) : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              border: const Border(
                                top: BorderSide(color: Color(0xFF79747E), width: 1),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'PM',
                              style: TextStyle(
                                color: !_isAM ? const Color(0xFF633B48) : const Color(0xFF49454F),
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Keyboard icon
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/keyboard_icon.png', // Replace with actual image path
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        // Toggle keyboard input
                      },
                      tooltip: 'Toggle keyboard input',
                    ),
                  ),
                ),

                // Cancel and OK buttons
                Row(
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF65558F),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Convert string hour to int, handling 12-hour format
                        int hourValue = int.parse(_hour);
                        if (!_isAM && hourValue < 12) {
                          hourValue += 12;
                        } else if (_isAM && hourValue == 12) {
                          hourValue = 0;
                        }

                        widget.onConfirm(TimeOfDay(
                          hour: hourValue,
                          minute: int.parse(_minute)
                        ));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF65558F),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}