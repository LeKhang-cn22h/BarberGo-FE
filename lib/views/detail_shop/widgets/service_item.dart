import 'package:barbergofe/core/constants/color.dart';
import 'package:flutter/material.dart';

class ServiceItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final String name;
  final String time;
  final String price;
  final VoidCallback onTap;

  const ServiceItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.name,
    required this.time,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey),
          boxShadow: [
            isSelected
                ? BoxShadow(
              color: AppColors.primary,
              spreadRadius: 4,
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
                : BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon và cột name/time
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 45,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(), // đẩy giá ra phải

            // Giá
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}