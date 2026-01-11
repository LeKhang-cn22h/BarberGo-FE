import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class OwnerTimeSlotItem extends StatelessWidget {
  final TimeSlotModel timeSlot;
  final VoidCallback onTap;
  final VoidCallback onToggleAvailability;

  const OwnerTimeSlotItem({
    super.key,
    required this.timeSlot,
    required this.onTap,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(10),
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
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDurationText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge & toggle
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: timeSlot.isAvailable
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        timeSlot.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: timeSlot.isAvailable ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeSlot.isAvailable ? 'Trống' : 'Đã đặt',
                        style: TextStyle(
                          color: timeSlot.isAvailable
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Toggle button
                InkWell(
                  onTap: onToggleAvailability,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          timeSlot.isAvailable ? Icons.lock : Icons.lock_open,
                          size: 12,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeSlot.isAvailable ? 'Đóng' : 'Mở',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Edit icon
            Icon(
              Icons.edit,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!timeSlot.isAvailable) return Colors.grey[50]!;
    return Colors.white;
  }

  Color _getBorderColor() {
    if (!timeSlot.isAvailable) return Colors.grey[300]!;
    return Colors.blue.shade200;
  }

  Color _getIconBackgroundColor() {
    if (!timeSlot.isAvailable) return Colors.grey[200]!;
    return Colors.blue.shade50;
  }

  Color _getIconColor() {
    if (!timeSlot.isAvailable) return Colors.grey;
    return Colors.blue.shade700;
  }

  String _getDurationText() {
    final duration = timeSlot.duration;
    final minutes = duration.inMinutes;
    return '$minutes phút';
  }
}