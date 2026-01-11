import 'package:flutter/material.dart';

class OwnerServiceItem extends StatelessWidget {
  final int index;
  final String name;
  final String time;
  final String price;
  final VoidCallback onEdit;    // Hành động sửa

  const OwnerServiceItem({
    super.key,
    required this.index,
    required this.name,
    required this.time,
    required this.price,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Icon hoặc Số thứ tự (Trang trí)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cut, size: 20, color: Colors.blue[700]),
          ),

          const SizedBox(width: 14),

          // 2. Cột thông tin (Tên + Thời gian)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                          fontSize: 13
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Giá tiền
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.green,
            ),
          ),

          // 4. Nút Hành động (Sửa)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade300 // Đường kẻ dọc
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                tooltip: "Chỉnh sửa",
                onPressed: onEdit, // Gọi ngược lên cha
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          )
        ],
      ),
    );
  }
}