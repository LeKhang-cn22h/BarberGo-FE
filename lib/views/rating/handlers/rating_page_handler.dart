import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/rating/rating_model.dart';
import 'package:barbergofe/viewmodels/rating/rating_viewmodel.dart';
import 'package:barbergofe/views/rating/widgets/update_rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RatingPageHandler {
  final BuildContext context;
  final RatingViewModel viewModel;

  RatingPageHandler({
    required this.context,
    required this.viewModel,
  });

  // ==================== DATA LOADING ====================

  Future<void> loadUserRatings() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) return;

    await viewModel.fetchUserRatings(userId);
  }

  // ==================== UPDATE RATING ====================

  Future<void> handleUpdateRating(RatingWithBarber rating) async {
    final result = await showDialog<UpdateRatingResult>(
      context: context,
      builder: (context) => UpdateRatingDialog(rating: rating),
    );

    if (result == null || !context.mounted) return;

    switch (result.action) {
      case UpdateRatingAction.update:
        if (result.newScore != null) {
          await _executeUpdate(rating, result.newScore!);
        }
        break;
      case UpdateRatingAction.delete:
        await _executeDelete(rating);
        break;
      case UpdateRatingAction.cancel:
        break;
    }
  }

  Future<void> _executeUpdate(RatingWithBarber rating, double newScore) async {
    final success = await viewModel.updateRating(
      rating.id,
      newScore,
      rating.barberId ?? '',
      rating.userId ?? '',
    );

    if (context.mounted) {
      _showSnackBar(
        success ? ' Cập nhật đánh giá thành công' : ' ${viewModel.error}',
        success,
      );

      if (success) await loadUserRatings();
    }
  }

  // ==================== DELETE RATING ====================

  Future<void> _executeDelete(RatingWithBarber rating) async {
    final confirmed = await _showDeleteConfirmation(rating);

    if (confirmed != true || !context.mounted) return;

    final success = await viewModel.deleteRating(
      rating.id,
      rating.barberId ?? '',
      rating.userId ?? '',
    );

    if (context.mounted) {
      _showSnackBar(
        success ? ' Đã xóa đánh giá' : ' ${viewModel.error}',
        success,
      );

      if (success) await loadUserRatings();
    }
  }

  Future<bool?> _showDeleteConfirmation(RatingWithBarber rating) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa đánh giá cho "${rating.barber?.name ?? "barber này"}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION ====================

  void navigateToBarberDetail(String barberId) {
    context.pushNamed(
      'detail',
      pathParameters: {'id': barberId},
    );
  }

  void navigateToHome() {
    context.goNamed('home');
  }

  // ==================== UI HELPERS ====================

  void _showSnackBar(String message, bool isSuccess) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}