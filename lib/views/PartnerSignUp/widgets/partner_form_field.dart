import 'package:flutter/material.dart';

class PartnerFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const PartnerFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}