import 'dart:async';

import 'package:barbergofe/views/OTP/widgets/opt_header.dart';
import 'package:flutter/material.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/otp_timer.dart';
import '../widgets/send_button.dart';
import '../widgets/otp_footer_shapes.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> controllers =
  List.generate(6, (index) => TextEditingController());
  int seconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  void _onSubmit() {
    String otp = controllers.map((e) => e.text).join();
    print("OTP gửi đi: $otp");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const OptHeader(
                  title: "Xác minh OTP",
                  subtitle: "Nhập mã OTP đã gửi đến số điện thoại của bạn",
                ),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        6,
                            (i) => OtpInputField(controller: controllers[i]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    OtpTimer(
                      seconds: seconds,
                      onResend: () {
                        if (seconds == 0) {
                          setState(() => seconds = 60);
                          _startTimer();
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    SendButton(onPressed: _onSubmit),
                  ],
                ),

                const OtpFooterShapes(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
