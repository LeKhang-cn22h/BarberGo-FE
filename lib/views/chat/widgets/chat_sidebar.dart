import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/viewmodels/chat/Chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatSidebar extends StatelessWidget {
  final bool isMobile;

  const ChatSidebar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, vm, _) {
        return Container(
          // Dùng SafeArea nếu là mobile để tránh tai thỏ
          color: AppColors.secondary,
          child: SafeArea(
            bottom: false, // Không cần safe area ở dưới
            right: false,
            left: isMobile, // Chỉ cần left safe area nếu là drawer
            top: isMobile,  // Chỉ cần top safe area nếu là drawer
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      vm.createNewSession();
                      if (isMobile) Navigator.pop(context); // Đóng drawer sau khi tạo
                    },
                    child: const Text("Trò chuyện mới"),
                  ),
                  const SizedBox(height: 20),
                  const Text("Gần đây", style: AppTextStyles.h2),
                  const SizedBox(height: 20),
                  Expanded(
                    child: vm.isLoadingSessions
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : ListView.builder(
                      itemCount: vm.sessions.length,
                      itemBuilder: (context, index) {
                        final session = vm.sessions[index];
                        final isSelected = session.id == vm.currentSessions; // Check lại tên biến trong ViewModel của bạn (currentSessionId hay currentSessions)

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.black),
                            title: Text(
                              session.title,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? IconButton(
                              onPressed: () => vm.deleteSession(session.id),
                              icon: const Icon(Icons.delete, size: 16, color: Colors.white70),
                            )
                                : null,
                            onTap: () {
                              vm.selectSession(session.id);
                              // QUAN TRỌNG: Đóng Drawer nếu đang ở mobile
                              if (isMobile) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}