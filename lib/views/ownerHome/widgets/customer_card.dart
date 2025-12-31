// lib/views/ownerHome/widgets/customer_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';

class CustomerCard extends StatelessWidget {
  final BookingModel booking;
  final OwnerHomeViewModel viewModel;

  const CustomerCard({
    super.key,
    required this.booking,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final minutesUntil = viewModel.getMinutesUntil(booking);
    final customerName = booking.user?['full_name'] ?? 'Khách hàng';
    final phone = booking.user?['phone'] ?? '';

    return Card(
      elevation: 3,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[200]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  radius: 24,
                  child: const Icon(Icons.person, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            minutesUntil > 0
                                ? 'Còn $minutesUntil phút nữa'
                                : 'Đã đến giờ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Services info
            Text(
              'Dịch vụ: ${booking.servicesSummary} (${booking.totalDurationMin}p)',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: phone.isNotEmpty ? () => _makeCall(phone) : null,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Gọi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _checkIn(context),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Check-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _checkIn(BuildContext context) async {
    try {
      await viewModel.checkInCustomer(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã check-in thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}