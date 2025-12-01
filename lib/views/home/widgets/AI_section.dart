import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/views/home/widgets/AIConsultationItem.dart';
import 'package:flutter/material.dart';

class AiSection extends StatelessWidget {
  const AiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI tu van', style: AppTextStyles.heading,),
        const SizedBox(height: 12,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Aiconsultationitem(icon: Icons.face,label:  'AI tạo tóc'),
              const SizedBox(width: 30,),
              Aiconsultationitem(icon: Icons.medical_services_outlined, label: 'AI trị mụn'),
              const SizedBox(width: 30,),
              Aiconsultationitem(icon: Icons.chat_bubble_outline, label: 'AI chat'),

            ]
        )
      ],
    );
  }
}
