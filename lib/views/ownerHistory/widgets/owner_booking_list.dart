// lib/views/ownerHistory/widgets/owner_booking_list.dart

import 'package:flutter/material.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'owner_booking_item.dart';

class OwnerBookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final Function(BookingModel) onBookingTap;

  const OwnerBookingList({
    super.key,
    required this.bookings,
    required this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OwnerBookingItem(
            booking: booking,
            onTap: () => onBookingTap(booking),
          ),
        );
      },
    );
  }
}