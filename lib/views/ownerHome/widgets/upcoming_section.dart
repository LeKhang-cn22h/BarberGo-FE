// lib/views/ownerHome/widgets/upcoming_section.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';
import 'customer_card.dart';

class UpcomingSection extends StatelessWidget {
  final OwnerHomeViewModel viewModel;

  const UpcomingSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    //  Lọc chỉ lấy booking có status = 'confirmed'
    final confirmedBookings = viewModel.allBookings
        .where((booking) => booking.status.toLowerCase() == 'confirmed')
        .toList();

    // Sắp xếp theo thời gian bắt đầu
    confirmedBookings.sort((a, b) {
      final aTime = a.timeSlots?['start_time']?.toString() ?? '';
      final bTime = b.timeSlots?['start_time']?.toString() ?? '';
      return aTime.compareTo(bTime);
    });

    //  Lấy booking đầu tiên (gần nhất)
    final nextBooking = confirmedBookings.isNotEmpty ? confirmedBookings.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SẮP DIỄN RA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            //  Hiển thị số lượng booking đang chờ
            if (confirmedBookings.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${confirmedBookings.length - 1} khách đang chờ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (nextBooking != null)
          CustomerCard(
            booking: nextBooking,
            viewModel: viewModel,
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không có khách đang chờ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tất cả khách đã được phục vụ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}