import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TilteForgotPass extends StatelessWidget {
  const TilteForgotPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: (){
          context.pop();
        }, icon: Icon(Icons.arrow_back)),
        Text("Quên mật khẩu", style: AppTextStyles.heading,)
      ],
    );
  }
}
