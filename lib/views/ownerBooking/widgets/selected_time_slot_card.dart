// lib/views/time_slot/widgets/selected_time_slot_card.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class SelectedTimeSlotCard extends StatelessWidget {
  final TimeSlotModel timeSlot;
  final VoidCallback onClear;

  const SelectedTimeSlotCard({
    super.key,
    required this.timeSlot,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giờ hẹn đã chọn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeSlot.displayText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}