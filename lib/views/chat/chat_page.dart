import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat/Chat_viewmodel.dart';
import 'widgets/chat_area.dart';
import 'widgets/chat_sidebar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: const Color(0xFF131314),
          // Nếu là mobile, gán Sidebar vào drawer
          drawer: isMobile
              ? const Drawer(
            width: 300, // Độ rộng của drawer trên mobile
            child: ChatSidebar(isMobile: true),
          )
              : null,
          body: Row(
            children: [
              // Nếu KHÔNG phải mobile, hiện Sidebar ở cột trái
              if (!isMobile) ...[
                const SizedBox(
                  width: 260,
                  child: ChatSidebar(isMobile: false),
                ),
                Container(width: 1, color: Colors.white12),
              ],

              // Chat Area chiếm phần còn lại
              Expanded(
                child: ChatArea(showMobileMenu: isMobile),
              ),
            ],
          ),
        );
      },
    );
  }
}