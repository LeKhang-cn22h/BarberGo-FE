import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/models/chat/chat_message.dart'; // Check import path
import 'package:barbergofe/viewmodels/chat/Chat_viewmodel.dart'; // Check import path

class ChatArea extends StatefulWidget {
  final bool showMobileMenu;

  const ChatArea({super.key, this.showMobileMenu = false});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _textController.text;
    if (text.isEmpty) return;

    context.read<ChatViewModel>().sendMessage(text);
    _textController.clear();
    // ... code scroll cũ của bạn ...
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();
    final messages = viewModel.messages;

    return Column(
      children: [
        // --- HEADER CHO MOBILE (MỚI) ---
        if (widget.showMobileMenu)
          AppBar(
            backgroundColor: Colors.transparent, // Trong suốt để tiệp màu nền
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Mở Drawer
                Scaffold.of(context).openDrawer();
              },
            ),
            title: const Text("BarberAI Chat", style: TextStyle(color: Colors.white, fontSize: 18)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () => context.goNamed('home')
              )
            ],
          ),


        // --- Danh sách tin nhắn ---
        Expanded(
          child: viewModel.sessionId == null && messages.isEmpty // Lưu ý: check logic sessionId hay currentSessionId cho khớp viewmodel
              ? _buildWelcomeView()
              : viewModel.isLoadingMessages
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: messages.length + (viewModel.isSending ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("BarberAI đang trả lời...",
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                    ),
                  ),
                );
              }
              return _MessageBubble(message: messages[index]);
            },
          ),
        ),

        // --- Ô nhập liệu (Giữ nguyên) ---
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF131314),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2E2F),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Nhập câu hỏi tại đây...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        Icons.send_rounded,
                        color: viewModel.isSending ? Colors.grey : Colors.blueAccent
                    ),
                    onPressed: viewModel.isSending ? null : _sendMessage,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.auto_awesome, size: 60, color: Colors.blueAccent),
          SizedBox(height: 20),
          Text(
            "Xin chào, tôi có thể giúp gì?",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Chọn một cuộc hội thoại hoặc bắt đầu chat mới.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 600), // Không cho bubble quá dài
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF005C97) : const Color(0xFF2D2E2F), // Xanh cho user, Xám cho AI
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nội dung tin nhắn
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}