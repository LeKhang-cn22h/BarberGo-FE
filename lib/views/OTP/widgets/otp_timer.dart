import 'package:flutter/material.dart';

class OtpTimer extends StatelessWidget {
  final int seconds;
  final VoidCallback onResend;
  const OtpTimer({super.key, required this.seconds, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Còn $seconds giây, OTP hết hạn",
          style: TextStyle(
            fontSize: 20
          ),

        ),
        GestureDetector(
          onTap: seconds == 0? onResend : null,
          child: Text(
           seconds == 0 ? "Gửi lại ngay" : " ",
            style: TextStyle(
              color: seconds == 0 ? Colors.blue : Colors.grey,
              decoration: seconds == 0 ? TextDecoration.underline : TextDecoration.none

            ),
          )

        )
      ],
    );
  }
}
