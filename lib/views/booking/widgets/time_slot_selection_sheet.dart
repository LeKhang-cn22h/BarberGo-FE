import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'package:barbergofe/core/constants/color.dart';
import 'package:intl/intl.dart';

class TimeSlotSelectionSheet extends StatefulWidget {
  final List<TimeSlotModel> timeSlots;
  final TimeSlotModel? selectedTimeSlot;
  final Function(TimeSlotModel) onSelect;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const TimeSlotSelectionSheet({
    super.key,
    required this.timeSlots,
    this.selectedTimeSlot,
    required this.onSelect,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<TimeSlotSelectionSheet> createState() => _TimeSlotSelectionSheetState();
}

class _TimeSlotSelectionSheetState extends State<TimeSlotSelectionSheet> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _availableDates = [];

  @override
  void initState() {
    super.initState();
    _extractAvailableDates();
  }

  void _extractAvailableDates() {
    final dates = <DateTime>{};
    for (var slot in widget.timeSlots) {
      if (slot.isAvailable) {
        dates.add(DateTime(slot.slotDate.year, slot.slotDate.month, slot.slotDate.day));
      }
    }
    _availableDates.addAll(dates.toList()..sort());

    // Nếu không có ngày nào, thêm ngày hôm nay và ngày mai
    if (_availableDates.isEmpty) {
      final now = DateTime.now();
      _availableDates.add(now);
      _availableDates.add(now.add(const Duration(days: 1)));
    }
  }

  List<TimeSlotModel> _getTimeSlotsForDate(DateTime date) {
    return widget.timeSlots.where((slot) {
      return slot.slotDate.year == date.year &&
          slot.slotDate.month == date.month &&
          slot.slotDate.day == date.day &&
          slot.isAvailable;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay (${DateFormat('dd/MM').format(date)})';
    } else if (dateOnly == tomorrow) {
      return 'Ngày mai (${DateFormat('dd/MM').format(date)})';
    } else {
      return DateFormat('EEEE, dd/MM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeSlotsForSelectedDate = _getTimeSlotsForDate(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chọn thời gian',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (widget.onRefresh != null)
                    IconButton(
                      onPressed: widget.isLoading ? null : widget.onRefresh,
                      icon: widget.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.refresh),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date selector
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableDates.length,
              itemBuilder: (context, index) {
                final date = _availableDates[index];
                final isSelected = _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Selected date label
          Text(
            _formatDate(_selectedDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Time slots
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : timeSlotsForSelectedDate.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Không có khung giờ trống',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.onRefresh != null)
                    TextButton(
                      onPressed: widget.onRefresh,
                      child: const Text('Tải lại'),
                    ),
                ],
              ),
            )
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: timeSlotsForSelectedDate.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlotsForSelectedDate[index];
                final isSelected = widget.selectedTimeSlot?.id == timeSlot.id;

                return GestureDetector(
                  onTap: () {
                    widget.onSelect(timeSlot);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        timeSlot.formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mỗi khung giờ dành cho 1 khách hàng. Vui lòng chọn khung giờ phù hợp.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}