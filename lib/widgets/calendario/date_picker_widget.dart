import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  final Function() onCancel;
  final Function(DateTime) onConfirm;

  const DatePickerWidget({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = 'mm/dd/yyyy';
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      height: 229,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFECE6F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFCAC4D0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enter date',
                  style: TextStyle(
                    color: Color(0xFF1D1B20),
                    fontFamily: 'Roboto',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    height: 1,
                  ),
                  semanticsLabel: 'Enter date header',
                ),
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
                        'assets/images/calendar_icon.png', // Replace with actual image path
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                            _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
                          });
                        }
                      },
                      tooltip: 'Select date from calendar',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date input
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF65558F),
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          color: const Color(0xFFECE6F0),
                          child: const Text(
                            'Date',
                            style: TextStyle(
                              color: Color(0xFF65558F),
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.4,
                              height: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(
                            _dateController.text,
                            style: const TextStyle(
                              color: Color(0xFF1D1B20),
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                              height: 24/16, // lineHeight / fontSize
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                    widget.onConfirm(_selectedDate);
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
          ),
        ],
      ),
    );
  }
}