// lib/views/ownerBarber/widgets/edit_service_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barbergofe/models/service/service_model.dart';

class EditServiceDialog extends StatefulWidget {
  final ServiceModel service;

  const EditServiceDialog({
    super.key,
    required this.service,
  });

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.serviceName);
    _priceController = TextEditingController(text: widget.service.price.toString());
    _durationController = TextEditingController(text: widget.service.durationMin.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Chỉnh sửa dịch vụ'),
        content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên dịch vụ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cut),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên dịch vụ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                        labelText: 'Giá (VNĐ)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá';
                    }
                    final price = int.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Giá phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Thời gian (phút)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thời gian';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Thời gian phải lớn hơn 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
            ),
        ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context, {'action': 'delete'});
          },
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Xóa', style: TextStyle(color: Colors.red)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'action': 'update',
                'serviceName': _nameController.text.trim(),
                'price': int.parse(_priceController.text),
                'durationMin': int.parse(_durationController.text),
              });
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}