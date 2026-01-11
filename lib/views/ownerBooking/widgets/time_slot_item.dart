// lib/views/time_slot/widgets/time_slot_item.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeSlotModel timeSlot;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotItem({
    super.key,
    required this.timeSlot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: timeSlot.isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                color: _getIconColor(),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Time info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeSlot.formattedTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: timeSlot.isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDurationText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đã chọn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (!timeSlot.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đã đặt',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!timeSlot.isAvailable) return Colors.grey[100]!;
    if (isSelected) return Colors.blue.shade50;
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isSelected) return Colors.blue;
    if (!timeSlot.isAvailable) return Colors.grey[300]!;
    return Colors.grey[300]!;
  }

  Color _getIconBackgroundColor() {
    if (!timeSlot.isAvailable) return Colors.grey[200]!;
    if (isSelected) return Colors.blue.shade100;
    return Colors.blue.shade50;
  }

  Color _getIconColor() {
    if (!timeSlot.isAvailable) return Colors.grey;
    return Colors.blue;
  }

  String _getDurationText() {
    final duration = timeSlot.duration;
    final minutes = duration.inMinutes;
    return 'Thời lượng: $minutes phút';
  }
}