import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:barbergofe/views/profile/widgets/profile_header.dart';
import 'package:barbergofe/views/profile/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authVM, child) {
            final user = authVM.currentUser;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ==================== PROFILE HEADER ====================

                  ProfileHeader(
                    name: user?.fullName ?? 'Người dùng',
                    avatarUrl: user?.avatarUrl,
                  ),


                  // ==================== MENU ITEMS ====================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Thông tin cá nhân
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Thông tin cá nhân',
                          onTap: () {
                            context.pushNamed('personal');
                          },
                        ),

                        const SizedBox(height: 12),

                        // Đăng ký đối tác
                        ProfileMenuItem(
                          icon: Icons.people_outline,
                          title: 'Đăng ký đối tác',
                          onTap: () {
                            context.pushNamed('Partneregistration');
                          },
                        ),

                        const SizedBox(height: 12),

                        // Địa chỉ
                        ProfileMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Địa chỉ',
                          onTap: () {
                            // context.pushNamed('location_picker');
                            context.pushNamed('Map');
                          },
                        ),

                        const SizedBox(height: 12),

                        // Trạng thái hồ sơ
                        ProfileMenuItem(
                          icon: Icons.folder_outlined,
                          title: 'Trạng thái hồ sơ',
                          onTap: () {
                            context.pushNamed('AppointmentDetail');
                          },
                        ),

                        const SizedBox(height: 12),

                        // Cài đặt
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt',
                          onTap: () {
                            _showSettingsBottomSheet(context, authVM);
                          },
                        ),

                        const SizedBox(height: 32),
                        ProfileMenuItem(
                          icon: Icons.star,
                          title: 'Đánh giá',
                          onTap: () {
                            context.pushNamed('user_rating');
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== SETTINGS BOTTOM SHEET ====================

  void _showSettingsBottomSheet(BuildContext context, AuthViewModel authVM) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context, authVM);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== LOGOUT DIALOG ====================

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Logout
              await authVM.logout();

              // Navigate to login
              if (context.mounted) {
                context.pop(); // Close loading
                context.goNamed('signin');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}