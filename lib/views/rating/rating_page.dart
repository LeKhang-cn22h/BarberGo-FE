import 'package:barbergofe/models/rating/rating_model.dart';
import 'package:barbergofe/viewmodels/rating/rating_viewmodel.dart';
import 'package:barbergofe/views/rating/handlers/rating_page_handler.dart';
import 'package:barbergofe/views/rating/widgets/rating_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserRatingsPage extends StatefulWidget {
  const UserRatingsPage({super.key});

  @override
  State<UserRatingsPage> createState() => _UserRatingsPageState();
}

class _UserRatingsPageState extends State<UserRatingsPage> {
  final Set<int> _expandedIds = {};
  late RatingPageHandler _handler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHandler();
      _handler.loadUserRatings();
    });
  }

  void _initHandler() {
    final viewModel = context.read<RatingViewModel>();
    _handler = RatingPageHandler(
      context: context,
      viewModel: viewModel,
    );
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

  // ==================== UI STATES ====================

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
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _handler.loadUserRatings(),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
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
            onPressed: _handler.navigateToHome,
            icon: const Icon(Icons.search),
            label: const Text('Tìm cửa hàng'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(List<RatingWithBarber> ratings) {
    return RefreshIndicator(
      onRefresh: () => _handler.loadUserRatings(),
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
            onUpdate: () => _handler.handleUpdateRating(rating),
            onNavigate: () {
              if (rating.barberId != null) {
                _handler.navigateToBarberDetail(rating.barberId!);
              }
            },
          );
        },
      ),
    );
  }
}