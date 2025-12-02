import 'package:flutter/material.dart';

class BarberSearch extends StatelessWidget {
  final String hint;
  const BarberSearch({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2)
          )
        ]
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
