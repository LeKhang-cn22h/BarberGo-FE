// lib/pages/user_ratings/user_ratings_page.dart
import 'package:barbergofe/views/rating/Widgets/rating_card.dart' hide RatingCard;
import 'package:barbergofe/views/rating/Widgets/update_rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:barbergofe/viewmodels/rating/rating_viewmodel.dart';
import 'package:barbergofe/models/rating/rating_model.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'Widgets/rating_card.dart';

class UserRatingsPage extends StatefulWidget {
  const UserRatingsPage({super.key});

  @override
  State<UserRatingsPage> createState() => _UserRatingsPageState();
}

class _UserRatingsPageState extends State<UserRatingsPage> {
  final Set<int> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        context.goNamed('login');
      }
      return;
    }

    final ratingViewModel = context.read<RatingViewModel>();
    await ratingViewModel.fetchUserRatings(userId);
  }

  void _toggleExpanded(int ratingId) {
    setState(() {
      if (_expandedIds.contains(ratingId)) {
        _expandedIds.remove(ratingId);
      } else {
        _expandedIds.add(ratingId);
      }
    });
  }

  Future<void> _showUpdateDialog(RatingWithBarber rating) async {
    final result = await showDialog<UpdateRatingResult>(
      context: context,
      builder: (context) => UpdateRatingDialog(rating: rating),
    );

    if (result != null && mounted) {
      if (result.action == UpdateRatingAction.delete) {
        await _deleteRating(rating);
      } else if (result.action == UpdateRatingAction.update) {
        await _updateRating(rating, result.newScore!);
      }
    }
  }

  Future<void> _updateRating(RatingWithBarber rating, double newScore) async {
    final ratingViewModel = context.read<RatingViewModel>();
    final success = await ratingViewModel.updateRating(
      rating.id,
      newScore,
      rating.barberId ?? '',
      rating.userId ?? ''
    );

    if (mounted) {
      _showSnackBar(
        success ? ' Cập nhật thành công' : ' ${ratingViewModel.error}',
        success,
      );

      if (success) await _loadData();
    }
  }

  Future<void> _deleteRating(RatingWithBarber rating) async {
    final confirmed = await _showDeleteConfirmation(rating);

    if (confirmed == true && mounted) {
      final ratingViewModel = context.read<RatingViewModel>();
      final success = await ratingViewModel.deleteRating(
        rating.id,
        rating.barberId ?? '',
        rating.userId ?? ''
      );

      if (mounted) {
        _showSnackBar(
          success ? ' Đã xóa đánh giá' : ' ${ratingViewModel.error}',
          success,
        );

        if (success) await _loadData();
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(RatingWithBarber rating) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa đánh giá cho ${rating.barber?.name ?? "barber này"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá của tôi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<RatingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.userRatings.isEmpty) {
            return _buildLoadingState();
          }

          if (viewModel.error != null && viewModel.userRatings.isEmpty) {
            return _buildErrorState(viewModel.error!);
          }

          if (viewModel.userRatings.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSuccessState(viewModel.userRatings);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa đánh giá cửa hàng nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.goNamed('home'),
            icon: const Icon(Icons.search),
            label: const Text('Tìm cửa hàng'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(List<RatingWithBarber> ratings) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ratings.length,
        itemBuilder: (context, index) {
          final rating = ratings[index];
          final isExpanded = _expandedIds.contains(rating.id);

          return RatingCard(
            rating: rating,
            isExpanded: isExpanded,
            onTap: () => _toggleExpanded(rating.id),
            onUpdate: () => _showUpdateDialog(rating),
            onNavigate: () {
              if (rating.barberId != null) {
                context.pushNamed('detail_shop', pathParameters: {
                  'id': rating.barberId!,
                });
              }
            },
          );
        },
      ),
    );
  }
}