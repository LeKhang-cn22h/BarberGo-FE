import 'package:flutter/material.dart';

class OwnerBookingPage extends StatefulWidget {
  const OwnerBookingPage({super.key});

  @override
  State<OwnerBookingPage> createState() => _OwnerBookingPageState();
}

class _OwnerBookingPageState extends State<OwnerBookingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Barber"),),
    );
  }
}
