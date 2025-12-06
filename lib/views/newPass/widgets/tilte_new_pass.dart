import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:barbergofe/core/theme/text_styles.dart';

class TitleNewPass extends StatelessWidget {
  const TitleNewPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        Text(
          "Đặt lại mật khẩu",
          style: AppTextStyles.heading,
        ),
      ],
    );
  }
}