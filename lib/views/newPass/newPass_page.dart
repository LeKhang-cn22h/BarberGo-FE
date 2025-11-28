import 'package:barbergofe/views/OTP/widgets/otp_footer_shapes.dart';
import 'package:barbergofe/views/newPass/widgets/content_new_pass.dart';
import 'package:barbergofe/views/newPass/widgets/tilte_new_pass.dart';

import 'package:flutter/material.dart';
class NewpassPage extends StatefulWidget {
  const NewpassPage({super.key});

  @override
  State<NewpassPage> createState() => _NewpassPageState();
}

class _NewpassPageState extends State<NewpassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(child:  Stack(
        children: [
          // Title ở trên cùng
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TilteNewPass(),
          ),

          // Content ở giữa màn hình
          Center(
            child: ContentNewPass(),
          ),

          // Footer luôn ở dưới cùng
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: OtpFooterShapes(),
          ),
        ],
      ),)
    );
  }
}
