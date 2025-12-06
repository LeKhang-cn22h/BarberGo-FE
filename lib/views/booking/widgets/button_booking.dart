import 'package:flutter/material.dart';

class NextButtonBooking extends StatelessWidget {
  const NextButtonBooking({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: (){},
        child: Text("Đặt lịch cắt ngay"));
  }
}
