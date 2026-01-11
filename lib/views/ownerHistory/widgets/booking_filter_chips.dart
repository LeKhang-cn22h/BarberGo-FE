// lib/views/ownerHistory/widgets/booking_filter_chips.dart

import 'package:flutter/material.dart';

class BookingFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final bool showCounts;
  final int totalCount;
  final int confirmedCount;
  final int completedCount;
  final int cancelledCount;

  const BookingFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.showCounts = false,
    this.totalCount = 0,
    this.confirmedCount = 0,
    this.completedCount = 0,
    this.cancelledCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Tất cả',
              value: 'all',
              icon: Icons.all_inclusive,
              count: showCounts ? totalCount : null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Sắp tới',
              value: 'upcoming',
              icon: Icons.upcoming,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Đang chờ',
              value: 'confirmed',
              icon: Icons.pending,
              color: Colors.orange,
              count: showCounts ? confirmedCount : null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Hoàn thành',
              value: 'completed',
              icon: Icons.check_circle,
              color: Colors.green,
              count: showCounts ? completedCount : null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Đã hủy',
              value: 'cancelled',
              icon: Icons.cancel,
              color: Colors.red,
              count: showCounts ? cancelledCount : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
    int? count,
  }) {
    final isSelected = selectedFilter == value;
    final chipColor = color ?? Colors.grey;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 6),
          Text(label),
          if (count != null && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : chipColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => onFilterChanged(value),
      selectedColor: chipColor,
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}