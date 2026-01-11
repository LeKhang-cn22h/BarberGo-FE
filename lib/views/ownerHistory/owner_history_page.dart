import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/booking/owner_booking_history_viewmodel.dart';
import 'package:barbergofe/viewmodels/barber/owner_barber_viewmodel.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'widgets/booking_statistics_card.dart';
import 'widgets/booking_filter_chips.dart';
import 'widgets/owner_booking_list.dart';
import 'widgets/booking_detail_bottom_sheet.dart';

class OwnerHistoryPage extends StatefulWidget {
  const OwnerHistoryPage({super.key});

  @override
  State<OwnerHistoryPage> createState() => _OwnerHistoryPageState();
}

class _OwnerHistoryPageState extends State<OwnerHistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final barberViewModel = context.read<OwnerBarberViewModel>();

    if (barberViewModel.myBarber == null) {
      print('⚠️ No barber found');
      return;
    }

    final bookingViewModel = context.read<OwnerBookingHistoryViewModel>();
    await bookingViewModel.fetchBarberBookings(barberViewModel.myBarber!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OwnerBarberViewModel>(
      builder: (context, barberViewModel, child) {
        final barber = barberViewModel.myBarber;

        if (barber == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Vui lòng cập nhật thông tin tiệm trước',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(

          body: Consumer<OwnerBookingHistoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && !viewModel.hasBookings) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null && !viewModel.hasBookings) {
                return _buildErrorState(viewModel);
              }

              if (!viewModel.hasBookings) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => viewModel.refresh(),
                child: Column(
                  children: [
                    // Statistics
                    BookingStatisticsCard(
                      statistics: viewModel.getStatistics(),
                    ),

                    // ✅ Search bar + Refresh button
                    _buildSearchBar(viewModel),

                    // Filter chips
                    BookingFilterChips(
                      selectedFilter: viewModel.selectedFilter,
                      onFilterChanged: (filter) => viewModel.setFilter(filter),
                      showCounts: true,
                      totalCount: viewModel.totalBookings,
                      confirmedCount: viewModel.activeBookings,
                      completedCount: viewModel.completedBookings,
                      cancelledCount: viewModel.cancelledBookings,
                    ),

                    const Divider(height: 1),

                    // Booking list
                    Expanded(
                      child: viewModel.filteredBookings.isEmpty
                          ? _buildEmptyFilteredState(viewModel.selectedFilter)
                          : OwnerBookingList(
                        bookings: viewModel.filteredBookings,
                        onBookingTap: (booking) =>
                            _showBookingDetail(booking, viewModel),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ SỬA: Thêm nút refresh bên cạnh search bar
  Widget _buildSearchBar(OwnerBookingHistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên khách, dịch vụ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.searchBookings('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => viewModel.searchBookings(value),
            ),
          ),

          const SizedBox(width: 12),

          // ✅ Refresh button
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: viewModel.isLoading ? null : _loadBookings,
              icon: viewModel.isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                ),
              )
                  : const Icon(Icons.refresh),
              color: Colors.white,
              iconSize: 24,
              tooltip: 'Làm mới',
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(OwnerBookingHistoryViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.error ?? 'Có lỗi xảy ra',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBookings,
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
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch đặt nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lịch sử đặt của khách hàng sẽ hiển thị ở đây',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilteredState(String filter) {
    String message;
    switch (filter) {
      case 'confirmed':
        message = 'Không có lịch đang chờ';
        break;
      case 'completed':
        message = 'Chưa có lịch hoàn thành';
        break;
      case 'cancelled':
        message = 'Không có lịch bị hủy';
        break;
      case 'upcoming':
        message = 'Không có lịch sắp tới';
        break;
      default:
        message = 'Không tìm thấy kết quả';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showBookingDetail(
      BookingModel booking,
      OwnerBookingHistoryViewModel viewModel,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingDetailBottomSheet(
        booking: booking,
        isOwnerView: true,
        onStatusChanged: (newStatus) async {
          final success = await viewModel.updateBookingStatus(
            booking.id.toString(),
            newStatus,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? '✅ Đã cập nhật trạng thái'
                      : '❌ Cập nhật thất bại',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }

          if (success) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}