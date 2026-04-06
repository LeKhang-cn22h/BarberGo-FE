import 'package:flutter/material.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';

class CreateTimeSlotDialog extends StatefulWidget {
  final String barberId;
  final DateTime? initialDate;

  const CreateTimeSlotDialog({
    super.key,
    required this.barberId,
    this.initialDate,
  });

  @override
  State<CreateTimeSlotDialog> createState() => _CreateTimeSlotDialogState();
}

class _CreateTimeSlotDialogState extends State<CreateTimeSlotDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tạo khung giờ mới',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Thêm khung giờ có thể đặt lịch',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Chọn ngày
                _buildDateSelector(),

                const SizedBox(height: 16),

                // Chọn giờ bắt đầu
                _buildTimeSelector(
                  label: 'Giờ bắt đầu',
                  icon: Icons.schedule,
                  time: _startTime,
                  onTap: () => _selectTime(context, isStartTime: true),
                ),

                const SizedBox(height: 16),

                // Chọn giờ kết thúc
                _buildTimeSelector(
                  label: 'Giờ kết thúc',
                  icon: Icons.schedule,
                  time: _endTime,
                  onTap: () => _selectTime(context, isStartTime: false),
                ),

                const SizedBox(height: 16),

                // Trạng thái
                _buildAvailabilitySwitch(),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _handleCreate,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Tạo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
            Icon(Icons.calendar_today, color: Colors.blue.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngày',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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

  Widget _buildTimeSelector({
    required String label,
    required IconData icon,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: time != null ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: time != null ? Colors.blue.shade50 : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: time != null ? Colors.blue.shade700 : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time != null ? _formatTime(time) : 'Chọn giờ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: time != null ? Colors.black : Colors.grey,
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

  Widget _buildAvailabilitySwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAvailable ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.cancel,
            color: _isAvailable ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cho phép đặt lịch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _handleCreate() async {
    // 1. Kiểm tra đã chọn giờ chưa
    if (_startTime == null) {
      _showError('Vui lòng chọn giờ bắt đầu');
      return;
    }

    if (_endTime == null) {
      _showError('Vui lòng chọn giờ kết thúc');
      return;
    }

    // 2. Tạo DateTime đầy đủ
    final now = DateTime.now();
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    //  3. Kiểm tra giờ kết thúc phải sau giờ bắt đầu
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      _showError('Giờ kết thúc phải sau giờ bắt đầu');
      return;
    }

    //  4. Kiểm tra duration tối thiểu (ví dụ: 15 phút)
    final duration = end.difference(start);
    if (duration.inMinutes < 15) {
      _showError('Thời gian slot phải ít nhất 15 phút');
      return;
    }

    //  5. Kiểm tra không được tạo slot trong quá khứ
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (isToday) {
      // Nếu là hôm nay, kiểm tra giờ bắt đầu phải sau giờ hiện tại
      if (start.isBefore(now) || start.isAtSameMomentAs(now)) {
        _showError(
            'Không thể tạo khung giờ trong quá khứ. '
                'Hiện tại là ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
        );
        return;
      }

      final buffer = now.add(const Duration(minutes: 10));
      if (start.isBefore(buffer)) {
        _showError(
            'Vui lòng chọn giờ ít nhất 15 phút sau hiện tại để có thời gian chuẩn bị'
        );
        return;
      }
    }

    //  6. (Optional) Kiểm tra giờ làm việc hợp lý (8h-22h)
    if (_startTime!.hour < 6 || _endTime!.hour > 23) {
      final confirm = await _showConfirmDialog(
        'Giờ làm việc bất thường',
        'Bạn đang tạo khung giờ ngoài giờ làm việc thông thường (6h-23h). Tiếp tục?',
      );
      if (confirm != true) return;
    }

    // Tạo request
    final request = TimeSlotCreateRequest(
      barberId: widget.barberId,
      slotDate: _selectedDate,
      startTime: _formatTimeToString(_startTime!),
      endTime: _formatTimeToString(_endTime!),
      isAvailable: _isAvailable,
    );

    Navigator.pop(context, request);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
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

  Future<bool?> _showConfirmDialog(String title, String message) {
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
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}