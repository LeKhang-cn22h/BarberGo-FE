import 'package:flutter/material.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/core/constants/color.dart';
import 'package:intl/intl.dart';

class BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;
  final VoidCallback onClose;

  const BookingDetailSheet({
    super.key,
    required this.booking,
    this.onCancel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chi tiết đơn đặt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: booking.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: booking.statusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(booking.statusIcon, color: booking.statusColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  booking.statusText,
                  style: TextStyle(
                    color: booking.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking info
                  _buildInfoSection('Thông tin đơn đặt', [
                    _buildInfoItem('Mã đơn', '#${booking.id}'),
                    _buildInfoItem('Ngày đặt', booking.formattedDate),
                    if (booking.createdAt != null)
                      _buildInfoItem(
                        'Giờ đặt',
                        DateFormat('HH:mm').format(booking.createdAt!),
                      ),
                  ]),

                  const SizedBox(height: 24),

                  // Barber info
                  _buildInfoSection('Tiệm tóc', [
                    _buildInfoItem('Tên tiệm', booking.barberName),
                    if (booking.barber?['location'] != null)
                      _buildInfoItem(
                        'Địa chỉ',
                        booking.barber!['location']?.toString() ?? '',
                      ),
                  ]),

                  const SizedBox(height: 24),

                  // Time slot
                  _buildInfoSection('Thời gian', [
                    _buildInfoItem('Khung giờ', booking.formattedTime),
                    if (booking.timeSlot?['slot_date'] != null)
                      _buildInfoItem(
                        'Ngày',
                        DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(booking.timeSlot!['slot_date']),
                        ),
                      ),
                  ]),

                  const SizedBox(height: 24),

                  // Services
                  _buildInfoSection('Dịch vụ', [
                    if (booking.services != null && booking.services!.isNotEmpty)
                      ...booking.services!.map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service['service_name']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '${service['price']?.toString() ?? '0'}đ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ]),

                  const SizedBox(height: 24),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryItem('Tổng thời gian', booking.formattedDuration),
                        const SizedBox(height: 8),
                        _buildSummaryItem('Tổng tiền', booking.formattedPrice),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          if (onCancel != null && booking.canCancel)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Hủy đơn đặt'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}