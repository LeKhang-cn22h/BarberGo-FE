import 'package:barbergofe/viewmodels/profile/profile_viewmodel.dart';
import 'package:barbergofe/views/profile/handlers/personal_info_handler.dart';
import 'package:barbergofe/views/profile/widgets/edit_avatar_bottom_sheet.dart';
import 'package:barbergofe/views/profile/widgets/profile_avatar.dart';
import 'package:barbergofe/views/profile/widgets/profile_loading_overlay.dart';
import 'package:barbergofe/views/profile/widgets/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // Đổi từ late sang nullable
  PersonalInfoHandler? _handler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHandler();
      final viewModel = context.read<ProfileViewModel>();
      if (viewModel.currentUser == null && !viewModel.isLoading) {
        _handler?.loadProfile();
      }
    });
  }

  void _initHandler() {
    final viewModel = context.read<ProfileViewModel>();
    setState(() {
      _handler = PersonalInfoHandler(
        context: context,
        viewModel: viewModel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        // Hiển thị loading nếu handler chưa sẵn sàng
        if (_handler == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: _handler!.goBack,
            ),
            title: const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: _buildBody(profileVM),
        );
      },
    );
  }

  Widget _buildBody(ProfileViewModel profileVM) {
    if (profileVM.isLoading && profileVM.currentUser == null) {
      return _buildLoadingState();
    }

    if (profileVM.errorMessage != null && profileVM.currentUser == null) {
      return _buildErrorState(profileVM.errorMessage!);
    }

    return Stack(
      children: [
        _buildContent(profileVM),
        ProfileLoadingOverlay(isVisible: profileVM.isUpdating),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _handler!.loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }


  Widget _buildContent(ProfileViewModel profileVM) {
    final user = profileVM.currentUser;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ProfileSection(
                  title: 'Ảnh đại diện',
                  trailing: TextButton(
                    onPressed: profileVM.isUpdating
                        ? null
                        : () => _showEditAvatarBottomSheet(),
                    child: const Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        color: Color(0xFF5B4B8A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  child: Center(
                    child: ProfileAvatar(
                      avatarUrl: user?.avatarUrl,
                      size: 100,
                    ),
                  ),
                ),

                const Divider(height: 32),

                ProfileSection(
                  title: 'Tên tài khoản',
                  trailing: TextButton(
                    onPressed: profileVM.isUpdating
                        ? null
                        : () => _showEditNameDialog(user?.fullName ?? ''),
                    child: const Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        color: Color(0xFF5B4B8A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  child: Text(
                    user?.fullName ?? 'Chưa cập nhật',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const Divider(height: 32),

                ProfileSection(
                  title: 'Số điện thoại',
                  trailing: TextButton(
                    onPressed: profileVM.isUpdating
                        ? null
                        : () => _showEditPhoneDialog(user?.phone ?? ''),
                    child: const Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        color: Color(0xFF5B4B8A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  child: Text(
                    user?.phone ?? 'Chưa cập nhật',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const Divider(height: 32),

                ProfileSection(
                  title: 'Email',
                  child: Text(
                    user?.email ?? 'Chưa cập nhật',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showEditAvatarBottomSheet() {
    EditAvatarBottomSheet.show(
      context,
      onPickFromGallery: _handler!.updateAvatar,
    );
  }

  void _showEditNameDialog(String currentName) {
    _handler!.showEditDialog(
      title: 'Chỉnh sửa tên',
      currentValue: currentName,
      onSave: _handler!.updateName,
    );
  }

  void _showEditPhoneDialog(String currentPhone) {
    _handler!.showEditDialog(
      title: 'Chỉnh sửa số điện thoại',
      currentValue: currentPhone,
      keyboardType: TextInputType.phone,
      onSave: _handler!.updatePhone,
    );
  }
}