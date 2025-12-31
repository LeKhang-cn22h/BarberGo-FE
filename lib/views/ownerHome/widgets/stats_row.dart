import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';
import 'stats_card.dart';

class StatsRow extends StatelessWidget {
  final OwnerHomeViewModel viewModel;

  const StatsRow({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            icon: Icons.group,
            title: 'Tổng Slot',
            value: viewModel.totalSlots.toString(),
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            icon: Icons.check_box,
            title: 'Đã đặt',
            value: '${viewModel.bookedSlots} (${viewModel.bookingPercentage.toStringAsFixed(0)}%)',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            icon: Icons.access_time,
            title: 'Còn trống',
            value: viewModel.availableSlots.toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}