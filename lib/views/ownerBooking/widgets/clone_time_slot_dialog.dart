import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class CloneTimeSlotDialog extends StatefulWidget {
  final String barberId;
  final List<TimeSlotModel> allTimeSlots;

  const CloneTimeSlotDialog({
    super.key,
    required this.barberId,
    required this.allTimeSlots,
  });

  @override
  State<CloneTimeSlotDialog> createState() => _CloneTimeSlotDialogState();
}

class _CloneTimeSlotDialogState extends State<CloneTimeSlotDialog> {
  DateTime? _sourceDate;
  DateTime? _targetDate;
  List<TimeSlotModel> _sourceDateSlots = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 24),

                // Chọn ngày nguồn
                _buildSourceDateSelector(),

                const SizedBox(height: 16),

                // Hiển thị slots của ngày nguồn
                if (_sourceDate != null && _sourceDateSlots.isNotEmpty)
                  _buildSourceSlotsPreview(),

                const SizedBox(height: 16),

                // Chọn ngày đích
                _buildTargetDateSelector(),

                const SizedBox(height: 24),

                // Buttons
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.content_copy,
            color: Colors.teal,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sao chép lịch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Copy khung giờ từ ngày khác',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceDateSelector() {
    final availableDates = _getAvailableDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event, color: Colors.teal.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Chọn ngày nguồn',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (availableDates.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chưa có ngày nào có khung giờ',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableDates.length,
              itemBuilder: (context, index) {
                final date = availableDates[index];
                final dateSlots = _getTimeSlotsForDate(date);
                final isSelected = _sourceDate != null && _isSameDay(_sourceDate!, date);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _sourceDate = date;
                      _sourceDateSlots = dateSlots;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.shade50 : null,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.teal : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(date),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dateSlots.length} khung giờ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSourceSlotsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Sẽ sao chép ${_sourceDateSlots.length} khung giờ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _sourceDateSlots.length,
            itemBuilder: (context, index) {
              final slot = _sourceDateSlots[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      slot.formattedTime,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTargetDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_available, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Chọn ngày đích',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectTargetDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _targetDate != null ? Colors.green.shade300 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _targetDate != null ? Colors.green.shade50 : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _targetDate != null ? Colors.green.shade700 : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày đích',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _targetDate != null ? _formatDate(_targetDate!) : 'Chọn ngày',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _targetDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final canClone = _sourceDate != null && _targetDate != null && _sourceDateSlots.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: canClone ? _handleClone : null,
          icon: const Icon(Icons.content_copy, size: 18),
          label: const Text('Sao chép'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      // Kiểm tra không trùng ngày nguồn
      if (_sourceDate != null && _isSameDay(picked, _sourceDate!)) {
        _showError('Ngày đích không thể trùng với ngày nguồn');
        return;
      }

      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _handleClone() {
    if (_sourceDate == null || _targetDate == null || _sourceDateSlots.isEmpty) {
      _showError('Vui lòng chọn đầy đủ thông tin');
      return;
    }

    // Tạo danh sách time ranges để clone
    final timeRanges = _sourceDateSlots.map((slot) {
      return {
        'start_time': slot.startTime,
        'end_time': slot.endTime,
      };
    }).toList();

    final request = TimeSlotBulkCreateRequest(
      barberId: widget.barberId,
      slotDate: _targetDate!,
      timeRanges: timeRanges,
    );

    Navigator.pop(context, request);
  }

  List<DateTime> _getAvailableDates() {
    final dates = <DateTime>{};
    for (var slot in widget.allTimeSlots) {
      dates.add(DateTime(
        slot.slotDate.year,
        slot.slotDate.month,
        slot.slotDate.day,
      ));
    }
    final sortedDates = dates.toList()..sort();
    return sortedDates;
  }

  List<TimeSlotModel> _getTimeSlotsForDate(DateTime date) {
    return widget.allTimeSlots.where((slot) {
      return _isSameDay(slot.slotDate, date);
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday, ${date.day}/${date.month}/${date.year}';
  }
}