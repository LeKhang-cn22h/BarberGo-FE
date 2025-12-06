import 'package:flutter/material.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/models/time_slot/time_slot_model.dart';
import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';

class BookingSummary extends StatelessWidget {
  final BarberModel? barber;
  final List<ServiceModel> services;
  final TimeSlotModel? timeSlot;
  final int totalPrice;
  final int totalDuration;

  const BookingSummary({
    super.key,
    this.barber,
    required this.services,
    this.timeSlot,
    required this.totalPrice,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tóm tắt đặt lịch',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 16),

            if (barber != null) _buildBarberInfo(),
            if (services.isNotEmpty) _buildServicesList(),
            if (timeSlot != null) _buildTimeSlotInfo(),

            const Divider(height: 32),

            _buildTotalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiệm tóc:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(barber!.name),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...services.map((service) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.serviceName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  '${service.price.toString()}đ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeSlotInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(timeSlot!.displayText),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTotalInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng thời gian:',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              _formatDuration(totalDuration),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Tổng tiền:',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              _formatPrice(totalPrice),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $remainingMinutes phút';
      }
    }
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }
}