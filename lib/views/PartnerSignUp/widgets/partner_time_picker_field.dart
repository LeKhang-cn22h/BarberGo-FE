import 'package:flutter/material.dart';

class PartnerTimePickerField extends StatelessWidget {
  final String label;
  final TextEditingController openController;
  final TextEditingController closeController;
  final VoidCallback onTapOpen;
  final VoidCallback onTapClose;

  const PartnerTimePickerField({
    super.key,
    required this.label,
    required this.openController,
    required this.closeController,
    required this.onTapOpen,
    required this.onTapClose,
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
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTapOpen,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: openController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.access_time, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 24,
                height: 2,
                color: Colors.grey,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: onTapClose,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: closeController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.access_time, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}