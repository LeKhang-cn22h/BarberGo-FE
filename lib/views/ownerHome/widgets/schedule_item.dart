// lib/views/ownerHome/widgets/schedule_item.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';

class ScheduleItem extends StatelessWidget {
  final TimeSlotModel timeSlot;
  final BookingModel? booking;
  final String status;
  final OwnerHomeViewModel viewModel;

  const ScheduleItem({
    super.key,
    required this.timeSlot,
    this.booking,
    required this.status,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: booking != null ? () => _showDetails(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        color: _getBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _getBorderColor(), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Time range
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${timeSlot.startTime.substring(0, 5)} - ${timeSlot.endTime.substring(0, 5)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Customer name or status
              if (booking != null) ...[
                Expanded(
                  child: Text(
                    booking!.user?['full_name'] ?? 'Khách hàng',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ] else ...[
                Text(
                  'Trống',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    if (booking == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BookingDetailSheet(
        booking: booking!,
        viewModel: viewModel,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case 'completed':
        return Colors.green[50]!;
      case 'in_progress':
        return Colors.orange[50]!;
      case 'booked':
        return Colors.blue[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getBorderColor() {
    switch (status) {
    case 'completed':
    return Colors.green[200]!;
    case 'in_progress':
      return Colors.orange[300]!;
      case 'booked':
        return Colors.blue[200]!;
      default:
        return Colors.grey[300]!;
    }
  }
  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'booked':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  IconData _getStatusIcon() {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.access_time_filled;
      case 'booked':
        return Icons.event;
      default:
        return Icons.event_available;
    }
  }
  String _getStatusText() {
    switch (status) {
      case 'completed':
        return 'Đã xong';
      case 'in_progress':
        return 'Đang chờ';
      case 'booked':
        return 'Đã đặt';
      default:
        return 'Slot Trống';
    }
  }
}
// Bottom sheet chi tiết booking
class _BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;
  final OwnerHomeViewModel viewModel;
  const _BookingDetailSheet({
    required this.booking,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết lịch hẹn',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.person, 'Khách hàng', booking.user?['full_name'] ?? ''),
          _buildInfoRow(Icons.phone, 'Số điện thoại', booking.user?['phone'] ?? ''),
          _buildInfoRow(Icons.access_time, 'Thời gian', booking.formattedTime),
          _buildInfoRow(Icons.work_outline, 'Dịch vụ', booking.servicesSummary),
          _buildInfoRow(Icons.schedule, 'Thời lượng', booking.formattedDuration),
          _buildInfoRow(Icons.attach_money, 'Tổng tiền', booking.formattedPrice),

          const SizedBox(height: 24),

          if (booking.status.toLowerCase() == 'in_progress')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await viewModel.completeBooking(booking.id);
                },
                icon: const Icon(Icons.done_all),
                label: const Text('Hoàn thành'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}