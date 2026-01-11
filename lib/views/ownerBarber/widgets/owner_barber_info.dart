import 'package:flutter/material.dart';

class OwnerBarberInfo extends StatelessWidget {
  final String name;
  final String location;
  final double rank;
  final String imagePath;
  final VoidCallback onEditImage;     // Bấm vào ảnh để đổi avatar
  final VoidCallback onEditName;      // Bấm vào tên để sửa tên
  final VoidCallback onEditLocation;  // Bấm vào địa chỉ để sửa vị trí
  final VoidCallback onTapStar;    // Bấm vào sao để xem

  const OwnerBarberInfo({
    super.key,
    required this.name,
    required this.imagePath,
    required this.location,
    required this.rank,
    required this.onEditImage,
    required this.onEditName,
    required this.onEditLocation,
    required this.onTapStar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- PHẦN 1: ẢNH ĐẠI DIỆN (Có nút sửa) ---
          Stack(
            children: [
              GestureDetector(
                onTap: onEditImage, // Gọi hành động sửa ảnh
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(imagePath),
                  // Thêm onBackgroundImageError để tránh crash nếu link ảnh lỗi
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onEditImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16), // Khoảng cách

          // --- PHẦN 2: THÔNG TIN CHI TIẾT ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2.1 Tên + Nút sửa
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                      onPressed: onEditName, // Gọi hành động sửa tên
                      tooltip: "Sửa tên",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 2.2 Vị trí + Nút sửa
                GestureDetector(
                  onTap: onEditLocation, // Bấm vào dòng địa chỉ cũng sửa được
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 2.3 Rank + Review (Bấm vào để xem chi tiết)
                InkWell(
                  onTap: onTapStar, // Dẫn sang màn hình review
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "$rank",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.amber[800]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}