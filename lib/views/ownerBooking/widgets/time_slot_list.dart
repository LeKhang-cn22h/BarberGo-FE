// lib/views/time_slot/widgets/time_slot_list.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'time_slot_item.dart';

class TimeSlotList extends StatelessWidget {
  final List<TimeSlotModel> timeSlots;
  final TimeSlotModel? selectedTimeSlot;
  final Function(TimeSlotModel) onTimeSlotTap;

  const TimeSlotList({
    super.key,
    required this.timeSlots,
    this.selectedTimeSlot,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Không có lịch trống cho ngày này',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isSelected = selectedTimeSlot?.id == slot.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TimeSlotItem(
            timeSlot: slot,
            isSelected: isSelected,
            onTap: () => onTimeSlotTap(slot),
          ),
        );
      },
    );
  }
}