import 'package:barbergofe/core/globals.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //  Lưu router ở state level
  late final GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }

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
                  ProfileHeader(
                    name: user?.fullName ?? 'Người dùng',
                    avatarUrl: user?.avatarUrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Thông tin cá nhân',
                          onTap: () {
                            context.pushNamed('personal');
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.people_outline,
                          title: 'Đăng ký đối tác',
                          onTap: () {
                            context.pushNamed('Partneregistration');
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Địa chỉ',
                          onTap: () {
                            context.pushNamed('Map');
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.folder_outlined,
                          title: 'Trạng thái hồ sơ',
                          onTap: () {
                            context.pushNamed('AppointmentDetail');
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt',
                          onTap: () {
                            _showSettingsBottomSheet(context, authVM);
                          },
                        ),
                        const SizedBox(height: 12),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cài đặt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
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

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              AppGlobals.scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Đang đăng xuất...'),
                    ],
                  ),
                  duration: Duration(seconds: 10),
                ),
              );

              try {
                print(' [LOGOUT] Starting logout...');
                await authVM.logout();
                print(' [LOGOUT] Logout completed');

                AppGlobals.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

                //  DÙNG _router ĐÃ LƯU Ở STATE - LUÔN HOẠT ĐỘNG
                print(' [LOGOUT] Navigating with saved router...');
                _router.goNamed('signin');
                print(' [LOGOUT] Navigation successful');

              } catch (e) {
                print(' [LOGOUT] Error: $e');

                AppGlobals.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

                AppGlobals.scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Đăng xuất thất bại: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
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