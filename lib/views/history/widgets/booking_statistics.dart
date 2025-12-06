import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/booking/booking_history_viewmodel.dart';
import 'package:barbergofe/core/constants/color.dart';

class BookingStatistics extends StatelessWidget {
  final BookingHistoryViewModel viewModel;

  const BookingStatistics({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final stats = viewModel.getStatistics();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total bookings
            _buildStatItem(
              icon: Icons.calendar_today,
              label: 'Tổng đơn',
              value: stats['total'].toString(),
              color: AppColors.primary,
            ),
            const Divider(height: 16),

            // Active bookings
            _buildStatItem(
              icon: Icons.access_time,
              label: 'Sắp tới',
              value: stats['active'].toString(),
              color: Colors.orange,
            ),
            const Divider(height: 16),

            // Completed bookings
            _buildStatItem(
              icon: Icons.check_circle,
              label: 'Đã hoàn thành',
              value: stats['completed'].toString(),
              color: Colors.green,
            ),
            const Divider(height: 16),

            // Total spent
            _buildStatItem(
              icon: Icons.attach_money,
              label: 'Tổng chi tiêu',
              value: '${stats['totalSpent'].toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
              )}đ',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}