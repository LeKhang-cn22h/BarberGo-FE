import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';
import 'schedule_item.dart';

class ScheduleList extends StatelessWidget {
  final OwnerHomeViewModel viewModel;

  const ScheduleList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.todayTimeSlots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Chưa có lịch trình hôm nay',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.todayTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = viewModel.todayTimeSlots[index];
        final booking = viewModel.getBookingForSlot(timeSlot);
        final status = viewModel.getScheduleItemStatus(timeSlot);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ScheduleItem(
            timeSlot: timeSlot,
            booking: booking,
            status: status,
            viewModel: viewModel,
          ),
        );
      },
    );
  }
}