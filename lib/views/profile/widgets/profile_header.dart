import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const ProfileHeader({
    Key? key,
    required this.name,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==================== AVATAR ====================

          ProfileAvatar(
            avatarUrl: avatarUrl,
            size: 120,
          ),

          const SizedBox(height: 16),

          // ==================== NAME ====================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),

            child: Text(
              name,
              style: AppTextStyles.heading
            ),
          ),
        ],
      ),
    );
  }
}