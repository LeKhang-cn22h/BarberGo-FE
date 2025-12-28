// lib/pages/user_ratings/widgets/rating_card.dart
import 'package:flutter/material.dart';
import 'package:barbergofe/models/rating/rating_model.dart';
import 'info_row.dart';

class RatingCard extends StatelessWidget {
  final RatingWithBarber rating;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onUpdate;
  final VoidCallback onNavigate;

  const RatingCard({
    super.key,
    required this.rating,
    required this.isExpanded,
    required this.onTap,
    required this.onUpdate,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: rating.barber?.imagepath != null
          ? Image.network(
        rating.barber!.imagepath!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      )
          : _defaultAvatar(),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: const Icon(Icons.store, size: 30, color: Colors.grey),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rating.barber?.name ?? 'Barber',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _buildStarRow(),
        const SizedBox(height: 4),
        Text(
          _formatDate(rating.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRow() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < (rating.score ?? 0)
                ? Icons.star
                : Icons.star_border,
            color: const Color(0xFFF3B51C),
            size: 18,
          );
        }),
        const SizedBox(width: 8),
        Text(
          rating.score?.toStringAsFixed(1) ?? '0.0',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            icon: Icons.calendar_today,
            label: 'Ngày đánh giá',
            value: _formatFullDate(rating.createdAt),
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.store,
            label: 'Mã cửa hàng',
            value: rating.barberId ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Sửa đánh giá'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}