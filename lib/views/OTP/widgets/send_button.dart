import 'package:barbergofe/core/theme/button_styles.dart';
import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SendButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppButtonStyles.roundedButtonBold2,

      child: const Text(
        "Gửi",
        style: TextStyle(fontSize: 20,
        fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
