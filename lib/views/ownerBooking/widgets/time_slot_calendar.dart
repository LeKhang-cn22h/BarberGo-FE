// lib/views/time_slot/widgets/time_slot_calendar.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TimeSlotCalendar extends StatelessWidget {
  final List<DateTime> availableDates;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const TimeSlotCalendar({
    super.key,
    required this.availableDates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: selectedDate,
          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarFormat: CalendarFormat.week,
          onDaySelected: (selectedDay, focusedDay) {
            if (_isDateAvailable(selectedDay)) {
              onDateSelected(selectedDay);
            }
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.shade200,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            disabledDecoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
          ),
          enabledDayPredicate: _isDateAvailable,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      ),
    );
  }

  bool _isDateAvailable(DateTime day) {
    return availableDates.any((date) => isSameDay(date, day));
  }
}