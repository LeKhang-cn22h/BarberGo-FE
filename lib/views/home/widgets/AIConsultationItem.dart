import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class Aiconsultationitem extends StatelessWidget {
  final IconData icon;
  final String label;
  const Aiconsultationitem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2)
          )
        ]
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black87,),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.caption,)
        ],
      ),
    );
  }
}
