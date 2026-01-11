// lib/views/ownerHistory/widgets/owner_booking_item.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/booking/booking_model.dart';

class OwnerBookingItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const OwnerBookingItem({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: booking.statusColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Customer info & status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with customer initial or image
                _buildCustomerAvatar(),
                const SizedBox(width: 12),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name (full_name)
                      Text(
                        _getCustomerName(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Booking ID hoặc thông tin phụ
                      Text(
                        'Booking #${booking.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status badge
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Booking details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.calendar_today,
                    label: 'Ngày',
                    value: booking.formattedDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.access_time,
                    label: 'Giờ',
                    value: booking.formattedTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Services
            _buildDetailItem(
              icon: Icons.content_cut,
              label: 'Dịch vụ',
              value: booking.servicesSummary,
            ),

            const SizedBox(height: 12),

            // Price & Duration
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.attach_money,
                    label: 'Giá',
                    value: booking.formattedPrice,
                    valueColor: Colors.green.shade700,
                    valueFontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.timer,
                    label: 'Thời gian',
                    value: booking.formattedDuration,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildCustomerAvatar() {
    final avatarUrl = booking.user?['avatar_url']?.toString();
    final customerName = _getCustomerName();
    final initial = customerName.isNotEmpty
        ? customerName.substring(0, 1).toUpperCase()
        : 'K';

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: Colors.grey.shade200,
        onBackgroundImageError: (_, __) {},
        child: Container(), // Fallback if image fails
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: _getCustomerAvatarColor(),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: booking.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: booking.statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            booking.statusIcon,
            size: 14,
            color: booking.statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            booking.statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: booking.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueFontWeight ?? FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================

  String _getCustomerName() {
    // Lấy từ users.full_name (theo API response structure)
    if (booking.user != null) {
      final fullName = booking.user!['full_name']?.toString();
      if (fullName != null && fullName.isNotEmpty) {
        return fullName;
      }
    }

    // Fallback
    return 'Khách hàng';
  }

  String _getCustomerEmail() {
    // Try to get email from user object
    if (booking.user != null) {
      final email = booking.user!['email']?.toString();
      if (email != null && email.isNotEmpty) {
        return email;
      }
    }

    // Fallback to empty or placeholder
    return 'Chưa có email';
  }

  Color _getCustomerAvatarColor() {
    // Generate color based on customer name for consistency
    final name = _getCustomerName();
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.cyan.shade400,
    ];

    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }
}