import 'package:flutter/material.dart';
import 'calendar_grid.dart';
import 'time_schedule.dart';
import '../../widgets/bottom_navigation.dart';

// Create a class for assets instead of using network images
class AppAssets {
  // Icons used across the app
  static const IconData logo = Icons.calendar_today;
  static const IconData calendarIcon = Icons.date_range;
  static const IconData dropdownIcon = Icons.arrow_drop_down;
  static const IconData addIcon = Icons.add;
  static const IconData nextMonth = Icons.keyboard_arrow_right;
  static const IconData prevMonth = Icons.keyboard_arrow_left;
}

class Calendario extends StatelessWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Académico'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      // Modificado: Cambiar la posición del FloatingActionButton
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const BottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildDatePicker(),
              _buildTimeSchedule(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 21.0, top: 12.0),
          child: Icon(
            AppAssets.logo,
            size: 24,
            color: Colors.black87,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, 11.0, 16.0, 12.0),
          child: Text(
            'Calendario',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: -0.4,
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
            semanticsLabel: 'Calendario app title',
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFECE6F0),
        borderRadius: BorderRadius.circular(28.0),
      ),
      height: 424,
      child: Column(
        children: [
          _buildDatePickerHeader(),
          _buildMonthSelector(),
          const Expanded(
            child: CalendarGrid(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDatePickerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 12.0, 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFCAC4D0),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Mon, Aug 17',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1D1B20),
                letterSpacing: 0,
                height: 1.0,
              ),
              semanticsLabel: 'Selected date: Monday, August 17',
            ),
          ),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  // Handle icon button tap
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    AppAssets.calendarIcon,
                    size: 24,
                    color: Color(0xFF49454F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 12.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                // Handle month selection
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 10.0, 4.0, 10.0),
                child: Row(
                  children: [
                    Text(
                      'August 2025',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF49454F),
                        letterSpacing: 0.1,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      AppAssets.dropdownIcon,
                      size: 18,
                      color: Color(0xFF49454F),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  AppAssets.prevMonth,
                  color: Color(0xFF49454F),
                ),
                onPressed: () {
                  // Handle previous month
                },
              ),
              IconButton(
                icon: const Icon(
                  AppAssets.nextMonth,
                  color: Color(0xFF49454F),
                ),
                onPressed: () {
                  // Handle next month
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 68,
            height: 40,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  // Handle cancel action
                },
                child: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF65558F),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 43,
            height: 40,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  // Handle OK action
                },
                child: const Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF65558F),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSchedule() {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Center(
        child: Container(
          width: 475,
          constraints: const BoxConstraints(maxWidth: double.infinity),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.fromLTRB(7.0, 2.0, 0, 2.0),
          child: const TimeSchedule(),
        ),
      ),
    );
  }

  // Modificado: Cambiar el estilo del FloatingActionButton para que coincida con la imagen
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF6750A4), // Color morado como en la imagen
      elevation: 6, // Añadir sombra
      child: const Icon(AppAssets.addIcon, color: Colors.white), // Ícono blanco
      onPressed: () {
        // Acción del botón
      },
    );
  }
}