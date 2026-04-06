import 'package:flutter/material.dart';

class AcneHistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  final VoidCallback onClearOld;

  const AcneHistoryAppBar({
    super.key,
    required this.onRefresh,
    required this.onClearOld,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Lịch sử phân tích'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_old',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, size: 20),
                  SizedBox(width: 8),
                  Text('Xóa kết quả cũ'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'clear_old') {
              onClearOld();
            }
          },
        ),
      ],
    );
  }
}