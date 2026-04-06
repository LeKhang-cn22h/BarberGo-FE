import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String status;

  const StatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config['color'],
              shape: BoxShape.circle,
            ),
            child: Icon(config['icon'], color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: config['color'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    final Map<String, Map<String, dynamic>> configs = {
      'pending': {
        'color': Colors.orange,
        'icon': Icons.access_time,
        'title': 'Đang chờ xử lý',
        'subtitle': 'Yêu cầu của bạn đang chờ đội ngũ Barber GO xem xét',
      },
      'confirmed': {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'title': 'Thành công',
        'subtitle': 'Yêu cầu đã được phê duyệt vui lòng kiểm tra email',
      },
      'cancelled': {
        'color': Colors.red,
        'icon': Icons.cancel,
        'title': 'Đã hủy',
        'subtitle': 'Yêu cầu đã bị hủy',
      },
    };

    return configs[status] ?? configs['pending']!;
  }
}