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

  // ==================== VALIDATION METHODS ====================

  /// Validate xem có thể update status không
  String? _validateStatusUpdate(BookingModel booking, String newStatus) {
    final now = DateTime.now();
    final slotDateTime = _parseSlotDateTime(booking);

    if (slotDateTime == null) {
      return 'Không thể xác định thời gian booking';
    }

    // 1. COMPLETED: Chỉ cho phép từ 15 phút trước start_time
    if (newStatus == 'completed') {
      final allowedTime = slotDateTime.subtract(const Duration(minutes: 15));

      if (now.isBefore(allowedTime)) {
        final minutesUntil = allowedTime.difference(now).inMinutes;
        return 'Chỉ có thể đánh dấu hoàn thành từ 15 phút trước giờ hẹn.\nCòn $minutesUntil phút nữa.';
      }
    }

    // 2. CANCELLED: Không cho hủy nếu đã completed
    if (newStatus == 'cancelled' && booking.status == 'completed') {
      return 'Không thể hủy booking đã hoàn thành';
    }

    // 3. CANCELLED: Phải hủy trước ít nhất 1 giờ
    if (newStatus == 'cancelled' && booking.status != 'cancelled') {
      final cancelDeadline = slotDateTime.subtract(const Duration(hours: 1));

      if (now.isAfter(cancelDeadline)) {
        return 'Không thể hủy booking khi vượt quá 1 giờ cho phép';
      }
    }
    return null; // Valid
  }

  /// Validate xem có thể đánh dấu "không đến" không
  String? _validateNoShow(BookingModel booking) {
    final now = DateTime.now();
    final endTime = _parseEndDateTime(booking);

    if (endTime == null) {
      return 'Không thể xác định thời gian kết thúc';
    }

    // 1. Chỉ cho no-show nếu status là confirmed
    if (booking.status != 'confirmed') {
      return 'Chỉ có thể đánh dấu no-show cho booking đang confirmed';
    }

    // 2. Chỉ cho no-show sau khi kết thúc
    if (now.isBefore(endTime)) {
      final minutesLeft = endTime.difference(now).inMinutes;
      return 'Chỉ có thể đánh dấu no-show sau giờ hẹn kết thúc.\nCòn $minutesLeft phút nữa.';
    }

    return null; // Valid
  }

  /// Parse start datetime từ booking
  DateTime? _parseSlotDateTime(BookingModel booking) {
    try {
      if (booking.timeSlots != null) {
        final slotDate = booking.timeSlots!['slot_date'] as String?;
        final startTime = booking.timeSlots!['start_time'] as String?;

        if (slotDate != null && startTime != null) {
          final date = DateTime.parse(slotDate);
          final timeParts = startTime.split(':');

          return DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }
    } catch (e) {
      print('❌ Parse slot datetime error: $e');
    }
    return null;
  }

  /// Parse end datetime từ booking
  DateTime? _parseEndDateTime(BookingModel booking) {
    try {
      if (booking.timeSlots != null) {
        final slotDate = booking.timeSlots!['slot_date'] as String?;
        final endTime = booking.timeSlots!['end_time'] as String?;

        if (slotDate != null && endTime != null) {
          final date = DateTime.parse(slotDate);
          final timeParts = endTime.split(':');

          return DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }
    } catch (e) {
      print('❌ Parse end datetime error: $e');
    }
    return null;
  }

  // ==================== UI HELPERS ====================

  /// Hiển thị validation error dialog
  void _showValidationError({
    required String title,
    required String message,
    IconData icon = Icons.warning_amber,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị confirmation dialog
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ==================== BUILD METHODS ====================

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
                    BookingStatisticsCard(
                      statistics: viewModel.getStatistics(),
                    ),
                    _buildSearchBar(viewModel),
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

  Widget _buildSearchBar(OwnerBookingHistoryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
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
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white70,
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

  // ==================== ACTION HANDLERS WITH VALIDATION ====================

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
        onStatusChanged: (newStatus) => _handleStatusUpdate(booking, newStatus, viewModel),
        onNoShow: () => _handleNoShow(booking, viewModel),
      ),
    );
  }

  /// Xử lý update status với validation
  Future<void> _handleStatusUpdate(
      BookingModel booking,
      String newStatus,
      OwnerBookingHistoryViewModel viewModel,
      ) async {
    // ===== VALIDATION =====
    final validationError = _validateStatusUpdate(booking, newStatus);

    if (validationError != null) {
      _showValidationError(
        title: 'Không thể cập nhật',
        message: validationError,
      );
      return;
    }
    // ======================

    // Show confirmation
    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận thay đổi',
      message: 'Bạn có chắc muốn đổi trạng thái sang "${_getStatusLabel(newStatus)}"?',
    );

    if (!confirmed) return;

    // Gọi API
    final success = await viewModel.updateBookingStatus(booking.id, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Đã cập nhật trạng thái' : '❌ Cập nhật thất bại'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pop(context); // Đóng bottom sheet
        await viewModel.refresh();
      }
    }
  }

  /// Xử lý đánh dấu "không đến" với validation
  Future<void> _handleNoShow(
      BookingModel booking,
      OwnerBookingHistoryViewModel viewModel,
      ) async {
    // ===== VALIDATION =====
    final validationError = _validateNoShow(booking);

    if (validationError != null) {
      _showValidationError(
        title: 'Không thể đánh dấu',
        message: validationError,
        icon: Icons.event_busy,
      );
      return;
    }
    // ======================

    // Show confirmation
    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận khách không đến',
      message: 'Booking sẽ tự động chuyển sang trạng thái "Đã hủy" với lý do "Khách không đến".',
    );

    if (!confirmed) return;

    // Gọi API
    final success = await viewModel.boomBookingStatus(booking.id);

    if (mounted) {
      Navigator.pop(context); // Đóng bottom sheet

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Đã ghi nhận khách không đến'
                : '❌ Thao tác thất bại: ${viewModel.error}',
          ),
          backgroundColor: success ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (success) {
        await viewModel.refresh();
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}