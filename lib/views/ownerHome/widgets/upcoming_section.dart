import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';
import 'customer_card.dart';

class UpcomingSection extends StatelessWidget {
  final OwnerHomeViewModel viewModel;

  const UpcomingSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'SẮP DIỄN RA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (viewModel.upcomingBooking != null)
          CustomerCard(
            booking: viewModel.upcomingBooking!,
            viewModel: viewModel,
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text(
                      'Không có lịch hẹn sắp tới',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}