import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HairHistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  final VoidCallback onClearOld;

  const HairHistoryAppBar({
    super.key,
    required this.onRefresh,
    required this.onClearOld,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Lịch sử tạo kiểu tóc'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
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