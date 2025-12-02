import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class Step1Booking extends StatefulWidget {
  final String nameStep;
  final String hint;
  final dynamic content;
  // content có thể là String hoặc List<String>

  const Step1Booking({
    super.key,
    required this.nameStep,
    required this.hint,
    required this.content,
  });

  @override
  State<Step1Booking> createState() => _Step1BookingState();
}

class _Step1BookingState extends State<Step1Booking> {
  String get displayText {
    // KHÔNG CÓ DỮ LIỆU → HIỆN HINT
    if (widget.content == null || widget.content.toString().isEmpty) {
      return widget.hint;
    }

    // TRƯỜNG HỢP content LÀ LIST
    if (widget.content is List) {
      final list = widget.content as List;

      if (list.isEmpty) return widget.hint;

      // LẤY PHẦN TỬ ĐẦU TIÊN
      return list.first.toString() + (list.length > 1 ? "..." : "");
    }

    // TRƯỜNG HỢP content LÀ STRING
    return widget.content.toString();
  }

  bool get hasContent {
    if (widget.content == null) return false;
    if (widget.content is List && (widget.content as List).isEmpty) return false;
    if (widget.content is String && widget.content.toString().isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TIÊU ĐỀ STEP
        Row(
          children: [
            Icon(
              Icons.circle,
              color: hasContent ? AppColors.primary : Colors.grey,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(widget.nameStep, style: AppTextStyles.h2),
          ],
        ),

        const SizedBox(height: 8),

        // NỘI DUNG STEP
        Container(
          height: 60,
          width: 324,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TEXT
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasContent ? Colors.black : Colors.grey,
                  ),
                ),
              ),

              Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
