import 'package:flutter/material.dart';

class TimePickerWidget extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final bool isAM;
  final Function(int hour, int minute, bool isAM) onTimeSelected;
  final VoidCallback onCancel;

  const TimePickerWidget({
    Key? key,
    required this.initialHour,
    required this.initialMinute,
    required this.isAM,
    required this.onTimeSelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late int _hour;
  late int _minute;
  late bool _isAM;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
    _isAM = widget.isAM;
  }

  String _formatHour() {
    int displayHour = _hour;
    if (_isAM) {
      if (displayHour == 0) {
        displayHour = 12;
      } else if (displayHour > 12) {
        displayHour -= 12;
      }
    } else {
      if (displayHour == 0) {
        displayHour = 12;
      } else if (displayHour > 12) {
        displayHour -= 12;
      }
    }
    return displayHour.toString().padLeft(2, '0');
  }

  String _formatMinute() {
    return _minute.toString().padLeft(2, '0');
  }

  void _incrementHour() {
    setState(() {
      _hour = (_hour + 1) % 24;
    });
  }

  void _decrementHour() {
    setState(() {
      _hour = (_hour - 1 + 24) % 24;
    });
  }

  void _incrementMinute() {
    setState(() {
      _minute = (_minute + 1) % 60;
    });
  }

  void _decrementMinute() {
    setState(() {
      _minute = (_minute - 1 + 60) % 60;
    });
  }

  void _toggleAMPM() {
    setState(() {
      _isAM = !_isAM;
      if (_isAM) {
        if (_hour >= 12) {
          _hour -= 12;
        }
      } else {
        if (_hour < 12) {
          _hour += 12;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFECE6F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter time',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF49454F),
            ),
          ),

          const SizedBox(height: 20),

          // Time selection row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour selector
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _incrementHour,
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Color(0xFF49454F),
                      ),
                    ),
                    Container(
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEADDFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF65558F), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatHour(),
                            style: const TextStyle(
                              fontSize: 45,
                              color: Color(0xFF4F378A),
                              height: 52/45,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 42,
                            color: const Color(0xFF65558F),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _decrementHour,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF49454F),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Hour',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF49454F),
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                ':',
                style: TextStyle(
                  fontSize: 57,
                  color: Color(0xFF1D1B20),
                ),
              ),

              // Minute selector
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _incrementMinute,
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Color(0xFF49454F),
                      ),
                    ),
                    Container(
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E0E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatMinute(),
                        style: const TextStyle(
                          fontSize: 45,
                          color: Color(0xFF1D1B20),
                          height: 52/45,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _decrementMinute,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF49454F),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Minute',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF49454F),
                      ),
                    ),
                  ],
                ),
              ),

              // AM/PM selector
              SizedBox(
                width: 52,
                child: Column(
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE6F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF79747E), width: 1),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isAM ? null : _toggleAMPM,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isAM ? const Color(0xFFFFD8E4) : Colors.transparent,
                                  border: const Border(
                                    bottom: BorderSide(color: Color(0xFF79747E), width: 1),
                                  ),
                                ),
                                child: Text(
                                  'AM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _isAM ? const Color(0xFF633B48) : const Color(0xFF49454F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isAM ? _toggleAMPM : null,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isAM ? Colors.transparent : const Color(0xFFFFD8E4),
                                ),
                                child: Text(
                                  'PM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _isAM ? const Color(0xFF49454F) : const Color(0xFF633B48),
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
            ],
          ),

          const SizedBox(height: 20),

          // Time picker actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clock icon
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFF49454F),
                  size: 24,
                ),
              ),

              // Action buttons
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF65558F),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onTimeSelected(_hour, _minute, _isAM);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF65558F),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}