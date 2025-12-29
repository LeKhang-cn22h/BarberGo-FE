import 'package:barbergofe/views/booking/widgets/booking_detail_sheet.dart';
import 'package:barbergofe/views/history/widgets/booking_card.dart';
import 'package:barbergofe/views/history/widgets/booking_filter_chip.dart';
import 'package:barbergofe/views/history/widgets/booking_statistics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/booking/booking_history_viewmodel.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'package:barbergofe/core/constants/color.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showStatistics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final viewModel = context.read<BookingHistoryViewModel>();
    await viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookingHistoryViewModel>();

    return Scaffold(
      body: Column(
        children: [
          // Statistics toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thống kê',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    viewModel.refreshUserBookings();
                  },
                  icon: const Icon(Icons.refresh),
                ),
                Switch(
                  value: _showStatistics,
                  onChanged: (value) {
                    setState(() {
                      _showStatistics = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Statistics
          if (_showStatistics && viewModel.totalBookings > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BookingStatistics(viewModel: viewModel),
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đơn đặt...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    viewModel.searchBookings('');
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
              ),
              onChanged: (value) {
                viewModel.searchBookings(value);
              },
            ),
          ),

          // Filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                BookingFilterChip(
                  label: 'Tất cả',
                  count: viewModel.totalBookings,
                  isSelected: viewModel.selectedFilter == 'all',
                  onTap: () => viewModel.setFilter('all'),
                ),
                const SizedBox(width: 8),
                BookingFilterChip(
                  label: 'Sắp tới',
                  count: viewModel.activeBookings,
                  isSelected: viewModel.selectedFilter == 'confirmed',
                  onTap: () => viewModel.setFilter('confirmed'),
                ),
                const SizedBox(width: 8),
                BookingFilterChip(
                  label: 'Đã hoàn thành',
                  count: viewModel.completedBookings,
                  isSelected: viewModel.selectedFilter == 'completed',
                  onTap: () => viewModel.setFilter('completed'),
                ),
                const SizedBox(width: 8),
                BookingFilterChip(
                  label: 'Đã hủy',
                  count: viewModel.cancelledBookings,
                  isSelected: viewModel.selectedFilter == 'cancelled',
                  onTap: () => viewModel.setFilter('cancelled'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bookings list
          Expanded(
            child: _buildBookingsList(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BookingHistoryViewModel viewModel) {
    if (viewModel.isLoading && viewModel.allBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.allBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshUserBookings(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (viewModel.filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              viewModel.selectedFilter == 'all'
                  ? 'Chưa có đơn đặt nào'
                  : 'Không có đơn đặt ${_getFilterLabel(viewModel.selectedFilter)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (viewModel.selectedFilter != 'all')
              TextButton(
                onPressed: () => viewModel.setFilter('all'),
                child: const Text('Xem tất cả'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refreshUserBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = viewModel.filteredBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              onTap: () {
                _showBookingDetails(booking, viewModel);
              },
              onCancel: viewModel.canCancel(booking)
                  ? () {
                _showCancelDialog(booking, viewModel);
              }
                  : null,
            ),
          );
        },
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'confirmed':
        return 'sắp tới';
      case 'completed':
        return 'đã hoàn thành';
      case 'cancelled':
        return 'đã hủy';
      default:
        return '';
    }
  }

  void _showBookingDetails(BookingModel booking, BookingHistoryViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BookingDetailSheet(
          booking: booking,
          onCancel: viewModel.canCancel(booking)
              ? () {
            Navigator.pop(context);
            _showCancelDialog(booking, viewModel);
          }
              : null,
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _showCancelDialog(BookingModel booking, BookingHistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Xác nhận hủy'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn có chắc chắn muốn hủy đơn đặt này?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      Icons.store,
                      'Tiệm: ${booking.barberName}',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.access_time,
                      'Giờ: ${booking.formattedTime}',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Giá: ${booking.formattedPrice}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng dialog

                // Hiển thị loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Gọi API hủy booking
                  await viewModel.cancelBooking(booking.id.toString());

                  // Đóng loading indicator
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  // ✅ QUAN TRỌNG: Fetch lại danh sách bookings
                  await viewModel.refreshUserBookings();

                  // Hiển thị thông báo thành công
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Đã hủy đơn đặt thành công'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Đóng loading indicator
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  // Hiển thị lỗi
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Lỗi: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hủy đơn'),
            ),
          ],
        );
      },
    );
  }

// Helper method để hiển thị thông tin
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}