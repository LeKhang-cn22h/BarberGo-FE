// lib/views/ownerBarber/widgets/edit_barber_name_dialog.dart

import 'package:flutter/material.dart';

class EditBarberNameDialog extends StatefulWidget {
  final String currentName;

  const EditBarberNameDialog({
    super.key,
    required this.currentName,
  });

  @override
  State<EditBarberNameDialog> createState() => _EditBarberNameDialogState();
}

class _EditBarberNameDialogState extends State<EditBarberNameDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa tên cửa hàng'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Tên cửa hàng',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên';
            }
            if (value.trim().length < 3) {
              return 'Tên phải có ít nhất 3 ký tự';
            }
            return null;
          },
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}