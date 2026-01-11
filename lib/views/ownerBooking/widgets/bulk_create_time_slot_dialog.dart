import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class BulkCreateTimeSlotDialog extends StatefulWidget {
  final String barberId;
  final DateTime? initialDate;

  const BulkCreateTimeSlotDialog({
    super.key,
    required this.barberId,
    this.initialDate,
  });

  @override
  State<BulkCreateTimeSlotDialog> createState() => _BulkCreateTimeSlotDialogState();
}

class _BulkCreateTimeSlotDialogState extends State<BulkCreateTimeSlotDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _slotDuration = 30; // Thời lượng mỗi slot (phút)
  int _breakDuration = 0; // Thời gian nghỉ giữa các slot (phút)

  final List<int> _durationOptions = [15, 30, 45, 60, 90, 120];
  final List<int> _breakOptions = [0, 5, 10, 15, 30];

  List<Map<String, String>> _generatedSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _generateSlots();
  }

  void _generateSlots() {
    _generatedSlots.clear();

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    int currentMinutes = startMinutes;

    while (currentMinutes + _slotDuration <= endMinutes) {
      final slotStart = _minutesToTimeOfDay(currentMinutes);
      final slotEnd = _minutesToTimeOfDay(currentMinutes + _slotDuration);

      _generatedSlots.add({
        'start_time': _formatTimeToString(slotStart),
        'end_time': _formatTimeToString(slotEnd),
      });

      currentMinutes += _slotDuration + _breakDuration;
    }

    setState(() {});
  }

  TimeOfDay _minutesToTimeOfDay(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // Chọn ngày
                  _buildDateSelector(),

                  const SizedBox(height: 16),

                  // Khung giờ làm việc
                  _buildWorkingHours(),

                  const SizedBox(height: 16),

                  // Cài đặt slot
                  _buildSlotSettings(),

                  const SizedBox(height: 24),

                  // Preview
                  _buildPreview(),

                  const SizedBox(height: 24),

                  // Buttons
                  _buildButtons(),
                ],
              ),
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
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.purple,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo hàng loạt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tự động tạo nhiều khung giờ',
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

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.purple.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngày',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Khung giờ làm việc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeButton(
                  label: 'Bắt đầu',
                  time: _startTime,
                  onTap: () => _selectTime(context, isStartTime: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeButton(
                  label: 'Kết thúc',
                  time: _endTime,
                  onTap: () => _selectTime(context, isStartTime: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Cài đặt khung giờ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thời lượng mỗi slot
          const Text(
            'Thời lượng mỗi slot',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durationOptions.map((duration) {
              final isSelected = duration == _slotDuration;
              return ChoiceChip(
                label: Text('$duration phút'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _slotDuration = duration;
                    _generateSlots();
                  });
                },
                selectedColor: Colors.green.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green.shade900 : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Thời gian nghỉ
          const Text(
            'Thời gian nghỉ giữa các slot',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _breakOptions.map((breakTime) {
              final isSelected = breakTime == _breakDuration;
              return ChoiceChip(
                label: Text(breakTime == 0 ? 'Không' : '$breakTime phút'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _breakDuration = breakTime;
                    _generateSlots();
                  });
                },
                selectedColor: Colors.orange.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.orange.shade900 : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Xem trước',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_generatedSlots.length} slots',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _generatedSlots.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Không có slot nào được tạo',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _generatedSlots.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final slot = _generatedSlots[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatTimeString(slot['start_time']!)} - ${_formatTimeString(slot['end_time']!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _generatedSlots.isEmpty ? null : _handleCreate,
          icon: const Icon(Icons.check, size: 18),
          label: Text('Tạo ${_generatedSlots.length} slots'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        _generateSlots();
      });
    }
  }

  void _handleCreate() {
    if (_generatedSlots.isEmpty) {
      _showError('Không có slot nào để tạo');
      return;
    }

    final request = TimeSlotBulkCreateRequest(
      barberId: widget.barberId,
      slotDate: _selectedDate,
      timeRanges: _generatedSlots,
    );

    Navigator.pop(context, request);
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatTimeString(String time) {
    final parts = time.split(':');
    return '${parts[0]}:${parts[1]}';
  }
}