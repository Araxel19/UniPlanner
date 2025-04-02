import 'package:flutter/material.dart';
import '../../widgets/calendario/date_picker_widget.dart';
import '../../widgets/calendario/time_picker_widget.dart';

class AggEvento extends StatefulWidget {
  const AggEvento({Key? key}) : super(key: key);

  @override
  State<AggEvento> createState() => _AggEventoState();
}

class _AggEventoState extends State<AggEvento> {
  bool _isEventSelected = true;
  bool _isDatePickerVisible = false;
  bool _isTimePickerVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App logo
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Image.asset(
                      'assets/images/logo.png', // Replace with actual image path
                      width: 54,
                      height: 54 / 2.57, // Maintaining aspect ratio of 2.57
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Title section with back button and save button
                  Padding(
                    padding: const EdgeInsets.only(top: 19, left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        Image.asset(
                          'assets/images/back_icon.png', // Replace with actual image path
                          width: 24,
                          height: 24,
                          semanticLabel: 'Go back',
                        ),

                        // Title and save button
                        Row(
                          children: [
                            // Title
                            const Padding(
                              padding: EdgeInsets.only(right: 56),
                              child: Text(
                                'Tarea',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                  height: 1.4,
                                ),
                                semanticsLabel: 'Task title',
                              ),
                            ),

                            // Save button
                            ElevatedButton(
                              onPressed: () {
                                // Save functionality
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFAEAEB2),
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Title input field
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 298),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFD9D9D9),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          width: double.infinity,
                          child: const Text(
                            'Agregar título',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Event/Task toggle buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Center(
                      child: Container(
                        width: 235,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Event button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEventSelected = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF65558F),
                                  minimumSize: const Size(0, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                                  child: const Text(
                                    'Evento',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 58),
                            // Task button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEventSelected = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF65558F).withValues(),
                                  minimumSize: const Size(0, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                                  child: const Text(
                                    'Tarea',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Add date chip
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 23),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDatePickerVisible = !_isDatePickerVisible;
                          if (_isDatePickerVisible) {
                            _isTimePickerVisible = false;
                          }
                        });
                      },
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFCAC4D0),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: const Text(
                          'Agregar fecha',
                          style: TextStyle(
                            color: Color(0xFF1D1B20),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // Date picker
                  if (_isDatePickerVisible)
                    Padding(
                      padding: const EdgeInsets.only(top: 13),
                      child: Center(
                        child: DatePickerWidget(
                          onCancel: () {
                            setState(() {
                              _isDatePickerVisible = false;
                            });
                          },
                          onConfirm: (date) {
                            setState(() {
                              _isDatePickerVisible = false;
                            });
                          },
                        ),
                      ),
                    ),

                  // Add time chip
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 23),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTimePickerVisible = !_isTimePickerVisible;
                          if (_isTimePickerVisible) {
                            _isDatePickerVisible = false;
                          }
                        });
                      },
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFCAC4D0),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: const Text(
                          'Agregar hora',
                          style: TextStyle(
                            color: Color(0xFF1D1B20),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // Time picker
                  if (_isTimePickerVisible)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: TimePickerWidget(
                          onCancel: () {
                            setState(() {
                              _isTimePickerVisible = false;
                            });
                          },
                          onConfirm: (time) {
                            setState(() {
                              _isTimePickerVisible = false;
                            });
                          },
                        ),
                      ),
                    ),

                  // Notes section
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCAC4D0),
                          width: 1,
                        ),
                        color: const Color(0xFFFEF7FF),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEADDFF),
                              ),
                            ),
                          ),
                          const Text(
                            'Agregar una nota',
                            style: TextStyle(
                              color: Color(0xFF1D1B20),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.15,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Home indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}