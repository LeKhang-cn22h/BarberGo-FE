import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TilteNewPass extends StatelessWidget {
  const TilteNewPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: (){
          context.pop();
        }, icon: Icon(Icons.arrow_back)),
        Text("Đặt mật khẩu mới", style: AppTextStyles.heading,)
      ],
    );
  }
}
