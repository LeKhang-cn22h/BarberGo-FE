
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
    final status = booking.status;

    return Card(
      elevation: 3,
      color: _getCardColor(status),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getBorderColor(status), width: 2),
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
                  backgroundColor: _getAvatarColor(status),
                  radius: 24,
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getIconColor(status),
                    size: 28,
                  ),
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
                //  Status badge
                _buildStatusBadge(status),
              ],
            ),

            const SizedBox(height: 12),

            // Services info
            Text(
              'Dịch vụ: ${booking.servicesSummary} (${booking.totalDurationMin}p)',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            //  Action buttons - thay đổi theo status
            _buildActionButtons(context, status, phone),
          ],
        ),
      ),
    );
  }

  // Status badge
  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: config['color'],
        ),
      ),
    );
  }

  //  Action buttons theo status
  Widget _buildActionButtons(BuildContext context, String status, String phone) {
    if (status == 'confirmed') {
      // Đã xác nhận → Hiển thị "Gọi", "Không đến" và "Đã đến"
      return Column(
        children: [
          // Nút "Đã đến" - nút chính
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _checkIn(context),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Đã đến'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Row chứa 2 nút phụ
          Row(
            children: [
              // Nút "Gọi"
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: phone.isNotEmpty ? () => _makeCall(context, phone) : null,
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Gọi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Nút "Không đến"
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _checkBoom(context),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Không đến'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (status == 'completed') {
      // Đã hoàn thành → Hiển thị badge "Đã hoàn thành"
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'Đã hoàn thành',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Status khác (pending, cancelled, etc.)
    return const SizedBox.shrink();
  }

  //  Helper methods
  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'confirmed':
        return {'label': 'Đã xác nhận', 'color': Colors.blue};
      case 'completed':
        return {'label': 'Hoàn thành', 'color': Colors.green};
      case 'cancelled':
        return {'label': 'Đã hủy', 'color': Colors.red};
      default:
        return {'label': status, 'color': Colors.grey};
    }
  }

  Color _getCardColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue[50]!;
      case 'completed':
        return Colors.green[50]!;
      case 'cancelled':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue[200]!;
      case 'completed':
        return Colors.green[200]!;
      case 'cancelled':
        return Colors.red[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getAvatarColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue[100]!;
      case 'completed':
        return Colors.green[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.person;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.person;
    }
  }

  Color _getIconColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  //  Gọi điện
  Future<void> _makeCall(BuildContext context, String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanPhone.isEmpty) {
        print(' Số điện thoại không hợp lệ');
        return;
      }

      final uri = Uri.parse('tel:$cleanPhone');
      print(' Đang gọi: $cleanPhone');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở ứng dụng gọi điện'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print(' Lỗi khi gọi: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gọi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //  Check-in
  Future<void> _checkBoom(BuildContext context) async {
    try {
      print(' Boom in booking: ${booking.id}');
      await viewModel.boomBooking(booking.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu khách không đến'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(' Boom error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _checkIn(BuildContext context) async {
    try {
      print(' Checking in booking: ${booking.id}');
      await viewModel.checkInCustomer(booking.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã check-in thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(' Check-in error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}