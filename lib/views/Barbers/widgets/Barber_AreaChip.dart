import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
class BarberAreachip extends StatelessWidget {
  final VoidCallback onTap;
  final String title;

  const BarberAreachip({super.key, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
          child: Text(title,
          style: TextStyle(
              color: Colors.white
          ),
          ),
      )
    );
  }
}
