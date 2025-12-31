
import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';
import 'package:flutter/material.dart';
class OwnerHeaderCard extends StatelessWidget {
  final OwnerHomeViewModel viewModel;

  const OwnerHeaderCard({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quản lý Cửa hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  viewModel.isStoreOpen ? 'Đang mở' : 'Đã đóng',
                  style: TextStyle(
                    fontSize: 14,
                    color: viewModel.isStoreOpen ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: viewModel.isStoreOpen,
                  onChanged: (_) => viewModel.toggleStoreStatus(),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}