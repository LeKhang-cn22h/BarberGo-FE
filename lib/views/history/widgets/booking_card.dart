// lib/views/history/widgets/booking_card.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/core/constants/color.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        booking.statusIcon,
                        color: booking.statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: booking.statusColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    booking.formattedDate,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Barber info
              Row(
                children: [
                  const Icon(Icons.store, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.barberName.isNotEmpty
                          ? booking.barberName
                          : 'Chưa có thông tin', //  Xử lý null/empty
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Services
              Row(
                children: [
                  const Icon(Icons.work_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.servicesSummary.isNotEmpty
                          ? booking.servicesSummary
                          : 'Chưa có dịch vụ', // Xử lý null/empty
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Time slot
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    booking.formattedTime.isNotEmpty
                        ? booking.formattedTime
                        : 'Chưa có thời gian', //  Xử lý null/empty
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer with price and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  // Chỉ hiển thị nút hủy khi có callback và booking có thể hủy
                  if (onCancel != null && booking.canCancel)
                    ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}