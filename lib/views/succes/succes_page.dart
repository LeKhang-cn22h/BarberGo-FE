import 'package:barbergofe/views/OTP/widgets/otp_footer_shapes.dart';
import 'package:barbergofe/views/succes/widgets/content_succes.dart';
import 'package:flutter/material.dart';

class SuccesPage extends StatefulWidget {
  const SuccesPage({super.key});

  @override
  State<SuccesPage> createState() => _SuccesPageState();
}

class _SuccesPageState extends State<SuccesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD6FAD6),
      body: SafeArea(child:
      Column(
        children: [
          Expanded(child: Center(
            child:ContentSucces(),

          )),

          OtpFooterShapes(),

        ],
      )
      ),
    );
  }
}
