import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/time_slot/time_slot_viewmodel.dart';
import 'package:barbergofe/viewmodels/barber/owner_barber_viewmodel.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'widgets/time_slot_calendar.dart';
import 'widgets/create_time_slot_dialog.dart';
import 'widgets/edit_time_slot_dialog.dart';
import 'widgets/bulk_create_time_slot_dialog.dart';
import 'widgets/clone_time_slot_dialog.dart';
import 'widgets/owner_time_slot_item.dart';

class OwnerBookingPage extends StatefulWidget {
  const OwnerBookingPage({super.key});

  @override
  State<OwnerBookingPage> createState() => _OwnerBookingPageState();
}

class _OwnerBookingPageState extends State<OwnerBookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeSlots();
    });
  }

  Future<void> _loadTimeSlots() async {
    final barberViewModel = context.read<OwnerBarberViewModel>();

    if (barberViewModel.myBarber == null) {
      print('⚠️ No barber found');
      return;
    }

    final timeSlotViewModel = context.read<TimeSlotViewModel>();
    await timeSlotViewModel.fetchTimeSlotsByBarber(
      barberViewModel.myBarber!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OwnerBarberViewModel>(
      builder: (context, barberViewModel, child) {
        final barber = barberViewModel.myBarber;

        if (barber == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quản lý lịch hẹn')),
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
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  style: AppTextStyles.headinglight
                  ),
              ],
            ),
            actions: [
              // ✅ THÊM: Menu với nhiều options
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'bulk':
                      _showBulkCreateDialog(barber.id);
                      break;
                    case 'clone':
                      _showCloneDialog(barber.id);
                      break;
                    case 'refresh':
                      _loadTimeSlots();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'bulk',
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 12),
                        Text('Tạo hàng loạt'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clone',
                    child: Row(
                      children: [
                        Icon(Icons.content_copy, size: 20),
                        SizedBox(width: 12),
                        Text('Sao chép lịch'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 12),
                        Text('Làm mới'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Consumer<TimeSlotViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && !viewModel.hasTimeSlots) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null && !viewModel.hasTimeSlots) {
                return _buildErrorState(viewModel);
              }

              if (!viewModel.hasTimeSlots) {
                return _buildEmptyState(barber.id);
              }

              return RefreshIndicator(
                onRefresh: () => viewModel.refresh(barber.id),
                child: Column(
                  children: [
                    // Calendar để chọn ngày
                    TimeSlotCalendar(
                      availableDates: _getAllDates(viewModel.timeSlots),
                      selectedDate: viewModel.selectedDate,
                      onDateSelected: (date) {
                        viewModel.selectDate(date);
                      },
                    ),

                    const Divider(height: 1),

                    // Hiển thị số lượng time slots
                    _buildTimeSlotHeader(viewModel),

                    // Danh sách time slots theo ngày đã chọn
                    Expanded(
                      child: _buildOwnerTimeSlotList(
                        viewModel.getTimeSlotsByDate(viewModel.selectedDate),
                        barber.id,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateTimeSlotDialog(barber.id),
            icon: const Icon(Icons.add),
            label: const Text('Tạo lịch'),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotHeader(TimeSlotViewModel viewModel) {
    final slotsForDate = viewModel.getTimeSlotsByDate(viewModel.selectedDate);
    final availableCount = slotsForDate.where((s) => s.isAvailable).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Icon(Icons.event_available, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            'Có ${slotsForDate.length} khung giờ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$availableCount trống',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerTimeSlotList(List<TimeSlotModel> timeSlots, String barberId) {
    if (timeSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Chưa có khung giờ nào cho ngày này',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCreateTimeSlotDialog(barberId),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tạo mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showBulkCreateDialog(barberId),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Tạo hàng loạt'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showCloneDialog(barberId),
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const Text('Sao chép'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OwnerTimeSlotItem(
            timeSlot: slot,
            onTap: () => _showEditTimeSlotDialog(slot),
            onToggleAvailability: () => _toggleAvailability(slot),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(TimeSlotViewModel viewModel) {
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
            onPressed: _loadTimeSlots,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String barberId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tạo khung giờ để khách có thể đặt lịch',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCreateTimeSlotDialog(barberId),
                icon: const Icon(Icons.add),
                label: const Text('Tạo khung giờ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showBulkCreateDialog(barberId),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Tạo hàng loạt'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== DIALOG HANDLERS ====================

  Future<void> _showCreateTimeSlotDialog(String barberId) async {
    final viewModel = context.read<TimeSlotViewModel>();

    final request = await showDialog<TimeSlotCreateRequest>(
      context: context,
      builder: (context) => CreateTimeSlotDialog(
        barberId: barberId,
        initialDate: viewModel.selectedDate,
      ),
    );

    if (request != null) {
      final success = await viewModel.createTimeSlot(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '✅ Đã tạo khung giờ mới' : '❌ Tạo thất bại',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // ✅ THÊM: Bulk create dialog
  Future<void> _showBulkCreateDialog(String barberId) async {
    final viewModel = context.read<TimeSlotViewModel>();

    final request = await showDialog<TimeSlotBulkCreateRequest>(
      context: context,
      builder: (context) => BulkCreateTimeSlotDialog(
        barberId: barberId,
        initialDate: viewModel.selectedDate,
      ),
    );

    if (request != null) {
      final success = await viewModel.bulkCreateTimeSlots(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Đã tạo ${request.timeRanges.length} khung giờ'
                  : '❌ Tạo thất bại',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ✅ THÊM: Clone dialog
  Future<void> _showCloneDialog(String barberId) async {
    final viewModel = context.read<TimeSlotViewModel>();

    final request = await showDialog<TimeSlotBulkCreateRequest>(
      context: context,
      builder: (context) => CloneTimeSlotDialog(
        barberId: barberId,
        allTimeSlots: viewModel.timeSlots,
      ),
    );

    if (request != null) {
      final success = await viewModel.bulkCreateTimeSlots(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Đã sao chép ${request.timeRanges.length} khung giờ'
                  : '❌ Sao chép thất bại',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showEditTimeSlotDialog(TimeSlotModel slot) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditTimeSlotDialog(timeSlot: slot),
    );

    if (result == null) return;

    final action = result['action'] as String;

    if (action == 'delete') {
      _handleDelete(slot);
    } else if (action == 'update') {
      _handleUpdate(slot, result['request'] as TimeSlotUpdateRequest);
    }
  }

  Future<void> _handleUpdate(
      TimeSlotModel slot,
      TimeSlotUpdateRequest request,
      ) async {
    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận cập nhật',
      message: 'Bạn có chắc muốn cập nhật khung giờ này?',
    );

    if (confirmed != true) return;

    final viewModel = context.read<TimeSlotViewModel>();
    final success = await viewModel.updateTimeSlot(slot.id, request);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Đã cập nhật khung giờ' : '❌ Cập nhật thất bại',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(TimeSlotModel slot) async {
    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc muốn xóa khung giờ "${slot.formattedTime}"?\n\n'
          'Lưu ý: Chỉ có thể xóa khung giờ chưa có booking.',
      isDestructive: true,
    );

    if (confirmed != true) return;

    final viewModel = context.read<TimeSlotViewModel>();
    final success = await viewModel.deleteTimeSlot(slot.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Đã xóa khung giờ' : '❌ Xóa thất bại (có thể đã có booking)',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAvailability(TimeSlotModel slot) async {
    final viewModel = context.read<TimeSlotViewModel>();
    final success = await viewModel.toggleTimeSlotAvailability(slot.id);

    if (mounted) {
      final newStatus = !slot.isAvailable;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Đã ${newStatus ? "mở" : "đóng"} khung giờ'
                : '❌ Thay đổi thất bại',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(isDestructive ? 'Xóa' : 'Xác nhận'),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getAllDates(List<TimeSlotModel> timeSlots) {
    final dates = <DateTime>{};
    for (var slot in timeSlots) {
      dates.add(DateTime(
        slot.slotDate.year,
        slot.slotDate.month,
        slot.slotDate.day,
      ));
    }
    return dates.toList()..sort();
  }
}