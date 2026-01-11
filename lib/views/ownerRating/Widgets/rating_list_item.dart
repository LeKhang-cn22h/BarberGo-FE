import 'package:flutter/material.dart';
import 'package:barbergofe/models/rating/rating_model.dart';
import 'package:intl/intl.dart';

class RatingListItem extends StatelessWidget {
  final RatingWithUser rating;

  const RatingListItem({
    super.key,
    required this.rating,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(),

              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.user?.fullName ?? 'Khách hàng',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rating.user?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Score
              _buildScoreChip(),
            ],
          ),

          const SizedBox(height: 12),

          // Stars
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (rating.score?.round() ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),

          const SizedBox(height: 8),

          // Date
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(rating.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (rating.user?.avatarUrl != null && rating.user!.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(rating.user!.avatarUrl!),
        backgroundColor: Colors.grey[200],
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.blue[100],
      child: Text(
        rating.user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildScoreChip() {
    final score = rating.score ?? 0;
    Color bgColor;
    Color textColor;

    if (score >= 4.5) {
      bgColor = Colors.green[100]!;
      textColor = Colors.green[700]!;
    } else if (score >= 3.5) {
      bgColor = Colors.blue[100]!;
      textColor = Colors.blue[700]!;
    } else if (score >= 2.5) {
      bgColor = Colors.orange[100]!;
      textColor = Colors.orange[700]!;
    } else {
      bgColor = Colors.red[100]!;
      textColor = Colors.red[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}