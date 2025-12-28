import 'package:barbergofe/models/rating/rating_model.dart';
import 'package:flutter/material.dart';

class UpdateRatingDialog extends StatefulWidget {
  final RatingWithBarber rating;
  const UpdateRatingDialog({
    super.key,
    required this.rating,
  });
  @override
  State<UpdateRatingDialog> createState() => _UpdateRatingDialogState();
}
class _UpdateRatingDialogState extends State<UpdateRatingDialog> {
  late double _selectedRating;
  @override
  void initState() {
    super.initState();
    _selectedRating = widget.rating.score ?? 0.0;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật đánh giá'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Đánh giá cho ${widget.rating.barber?.name ?? "Barber"}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Đánh giá hiện tại: ${widget.rating.score?.toStringAsFixed(1)} sao',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text('Chọn số sao mới:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          _buildStarRow(),
          const SizedBox(height: 10),
          Text(
            '${_selectedRating.toStringAsFixed(1)} sao',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              UpdateRatingResult(action: UpdateRatingAction.delete),
            );
          },
          child: const Text(
            'Xóa đánh giá',
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              UpdateRatingResult(action: UpdateRatingAction.cancel),
            );
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _selectedRating > 0
              ? () {
            Navigator.pop(
              context,
              UpdateRatingResult(
                action: UpdateRatingAction.update,
                newScore: _selectedRating,
              ),
            );
          }
              : null,
          child: const Text('Cập nhật'),
        ),
      ],
    );
  }
  Widget _buildStarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1.0;
        return IconButton(
          iconSize: 40,
          icon: Icon(
            _selectedRating >= star ? Icons.star : Icons.star_border,
            color: const Color(0xFFF3B51C),
          ),
          onPressed: () {
            setState(() {
              _selectedRating = star;
            });
          },
        );
      }),
    );
  }
}