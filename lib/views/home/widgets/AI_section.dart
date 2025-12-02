import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/views/home/widgets/AIConsultationItem.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:barbergofe/routes/route_names.dart';
class AiSection extends StatelessWidget {
  const AiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI tư vấn', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 30,
          children: [
            Aiconsultationitem(
              icon: Icons.face,
              label: 'AI tạo tóc',
            ),
            Aiconsultationitem(
              icon: Icons.medical_services_outlined,
              label: 'AI trị mụn',
              onTap: () {
                print("Nút AI trị mụn được bấm");
                context.goNamed('acne');
              },
            ),

            Aiconsultationitem(
              icon: Icons.chat_bubble_outline,
              label: 'AI chat',
            ),
          ],
        ),
      ],
    );
  }
}

