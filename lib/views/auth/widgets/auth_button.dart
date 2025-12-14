import 'package:flutter/material.dart';
import 'package:barbergofe/core/theme/button_styles.dart';
class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final String text;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.enabled,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: Text(text),
      ),
    );
  }
}

