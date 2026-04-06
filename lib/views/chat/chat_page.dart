import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/color.dart';
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
          backgroundColor: AppColors.background,
          drawer: isMobile
              ? Drawer(
            width: 300,
            child: Container(
              color: Colors.white,
              child: const ChatSidebar(isMobile: true),
            ),
          )
              : null,
          body: Column(
            children: [
              // ── Top App Bar ──
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2267539D),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 10),
                    child: Row(
                      children: [
                        // Nút back
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimaryLight,
                            size: 20,
                          ),
                          tooltip: 'Quay lại',
                        ),

                        // Nút menu (mobile)
                        if (isMobile)
                          Builder(
                            builder: (ctx) => IconButton(
                              onPressed: () =>
                                  Scaffold.of(ctx).openDrawer(),
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ),

                        // Avatar + Title
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'BarberGo AI',
                              style: TextStyle(
                                color: AppColors.textPrimaryLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Đang hoạt động',
                                  style: TextStyle(
                                    color: Color(0xCCFFFFFF),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Nút tạo chat mới
                        Consumer<ChatViewModel>(
                          builder: (_, vm, __) => IconButton(
                            onPressed: vm.isLoadingSessions
                                ? null
                                : () => vm.createNewSession(),
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.textPrimaryLight,
                              size: 26,
                            ),
                            tooltip: 'Cuộc trò chuyện mới',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ──
              Expanded(
                child: Row(
                  children: [
                    // Sidebar desktop
                    if (!isMobile) ...[
                      Container(
                        width: 260,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(
                              color: Color(0xFFE8E0F0),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const ChatSidebar(isMobile: false),
                      ),
                    ],

                    // Chat area
                    Expanded(
                      child: ChatArea(showMobileMenu: isMobile),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}