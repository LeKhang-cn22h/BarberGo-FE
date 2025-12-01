import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class OptHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const OptHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 32.0),
    child: Column(
      children: [
        Text(title,
        style: AppTextStyles.heading
    ),
          const SizedBox(height: 8),
        Text(subtitle,
        style: AppTextStyles.body,
        )

      ],
    ),
    );
  }
}
