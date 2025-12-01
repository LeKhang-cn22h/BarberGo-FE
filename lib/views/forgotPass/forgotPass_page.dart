import 'package:barbergofe/views/OTP/widgets/otp_footer_shapes.dart';
import 'package:barbergofe/views/forgotPass/widgets/content_forgot_pass.dart';
import 'package:barbergofe/views/forgotPass/widgets/tilte_forgot_pass.dart';
import 'package:flutter/material.dart';
class ForgotpassPage extends StatefulWidget {
  const ForgotpassPage({super.key});

  @override
  State<ForgotpassPage> createState() => _ForgotpassPageState();
}

class _ForgotpassPageState extends State<ForgotpassPage> {
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
            child: TilteForgotPass(),
          ),

          // Content ở giữa màn hình
          Center(
            child: ContentForgotPass(),
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
