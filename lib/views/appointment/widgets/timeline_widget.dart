import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatelessWidget {
  final AppointmentModel appointment;

  const TimelineWidget({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {
        'status': 'pending',
        'label': 'Đã gửi yêu cầu',
        'time': appointment.createdAt
      },
      {
        'status': 'confirmed',
        'label': 'Thành công',
        'time': appointment.updatedAt
      },
      {
        'status': 'cancelled',
        'label': 'Đã hủy',
        'time': appointment.updatedAt
      },
    ];

    final currentStatusIndex =
    statuses.indexWhere((item) => item['status'] == appointment.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < statuses.length; i++)
            Column(
              children: [
                _buildTimelineItem(
                  isActive: i <= currentStatusIndex,
                  isLast: i == statuses.length - 1,
                  label: statuses[i]['label'] as String,
                  time: appointment.status == statuses[i]['status']
                      ? _formatDateTime(statuses[i]['time'] as DateTime)
                      : null,
                ),
                if (i < statuses.length - 1) const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isActive,
    required bool isLast,
    required String label,
    String? time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
  }
}