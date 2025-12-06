import 'package:barbergofe/views/forgotPass/widgets/tilte_forgot_pass.dart';
import 'package:flutter/material.dart';
import 'widgets/content_forgot_pass.dart';

class ForgotpassPage extends StatelessWidget {
  const ForgotpassPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4B5B5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const TilteForgotPass(),

              const SizedBox(height: 40),

              // Content
              Center(child: ContentForgotPass()),
            ],
          ),
        ),
      ),
    );
  }
}