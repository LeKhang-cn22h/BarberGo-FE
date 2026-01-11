import 'package:barbergofe/views/ownerRating/Widgets/empty_rating_widget.dart';
import 'package:barbergofe/views/ownerRating/Widgets/rating_list_item.dart';
import 'package:barbergofe/views/ownerRating/Widgets/rating_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/rating/rating_viewmodel.dart';

class OwnerRatingPage extends StatefulWidget {
  final String barberId;

  const OwnerRatingPage({
    super.key,
    required this.barberId,
  });

  @override
  State<OwnerRatingPage> createState() => _OwnerRatingPageState();
}

class _OwnerRatingPageState extends State<OwnerRatingPage> {
  late RatingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<RatingViewModel>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchBarberRatings(widget.barberId);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Đánh giá của khách hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Consumer<RatingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.barberRatings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // Stats Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RatingStatsCard(
                      ratings: viewModel.barberRatings,
                    ),
                  ),
                ),

                // Rating List
                viewModel.barberRatings.isEmpty
                    ? const SliverFillRemaining(
                  child: EmptyRatingWidget(),
                )
                    : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final rating = viewModel.barberRatings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: RatingListItem(rating: rating),
                        );
                      },
                      childCount: viewModel.barberRatings.length,
                    ),
                  ),
                ),

                // Bottom Padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}