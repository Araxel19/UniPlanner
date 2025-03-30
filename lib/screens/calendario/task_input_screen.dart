import 'package:flutter/material.dart';
import '../../widgets/calendario/agg_time_picker_widget.dart';

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});

  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  bool isTaskSelected = true;
  TextEditingController titleController = TextEditingController();
  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool isAM = true;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimePickerWidget(
        initialHour: selectedTime.hour,
        initialMinute: selectedTime.minute,
        isAM: isAM,
        onTimeSelected: (hour, minute, isAM) {
          setState(() {
            selectedTime = TimeOfDay(hour: hour, minute: minute);
            this.isAM = isAM;
          });
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.chevron_left,
                          size: 24,
                          semanticLabel: 'Back',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tarea',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  // Save button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAEAEB2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title input and type selection
                      Column(
                        children: [
                          // Title input
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'Agregar título',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 16),

                          // Event/Task toggle
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isTaskSelected = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF65558F).withOpacity(isTaskSelected ? 0.5 : 1.0),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Evento',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isTaskSelected = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF65558F).withOpacity(isTaskSelected ? 1.0 : 0.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Tarea',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Time selection button
                          GestureDetector(
                            onTap: _showTimePicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCAC4D0), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Agregar hora',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1D1B20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Time picker (shown inline for demonstration)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE6F0),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
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
                                            const Text(
                                              '20',
                                              style: TextStyle(
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
                                      Container(
                                        height: 72,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6E0E9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '00',
                                          style: TextStyle(
                                            fontSize: 45,
                                            color: Color(0xFF1D1B20),
                                            height: 52/45,
                                          ),
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
                                  child: Container(
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECE6F0),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF79747E), width: 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFD8E4),
                                              border: Border(
                                                bottom: BorderSide(color: Color(0xFF79747E), width: 1),
                                              ),
                                            ),
                                            child: const Text(
                                              'AM',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF633B48),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'PM',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF49454F),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                      onPressed: () {},
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF65558F),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
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
                      ),

                      const SizedBox(height: 24),

                      // Notes section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF7FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCAC4D0), width: 1),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEADDFF),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Note placeholder
                            const Text(
                              'Agregar una nota',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1D1B20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom bar
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 134,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}