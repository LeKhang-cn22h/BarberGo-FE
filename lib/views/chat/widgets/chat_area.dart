import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/chat/Chat_viewmodel.dart';
import 'message_bubble.dart';
import 'barber_suggest_card.dart';

class ChatArea extends StatefulWidget {
  final bool showMobileMenu;
  const ChatArea({super.key, required this.showMobileMenu});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Consumer<ChatViewModel>(
      builder: (context, vm, _) {
        // Auto scroll khi có message mới
        if (vm.messages.isNotEmpty) _scrollToBottom();

        return Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1E1E1E),
              child: Row(
                children: [
                  if (widget.showMobileMenu)
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  const Expanded(
                    child: Text(
                      'BarberGo AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: vm.isLoadingMessages
                  ? const Center(child: CircularProgressIndicator())
                  : vm.messages.isEmpty
                  ? _buildEmptyState(vm)
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: vm.messages.length,
                itemBuilder: (context, index) =>
                    MessageBubble(message: vm.messages[index]),
              ),
            ),

            // Barber suggest results
            if (vm.suggestResults.isNotEmpty) ...[
              Container(
                height: 140,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.suggestResults.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => BarberSuggestCard(
                    result: vm.suggestResults[index],
                    onTap: () {
                      // Gửi câu hỏi chi tiết về tiệm này
                      vm.sendMessage(
                        'Cho tôi biết thêm về ${vm.suggestResults[index].barberName}',
                      );
                      vm.clearSuggest();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Input box
            _buildInputBox(context, vm),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ChatViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cut, size: 48, color: Colors.white30),
          const SizedBox(height: 12),
          const Text(
            'Xin chào! Tôi có thể giúp gì cho bạn?',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Gợi ý nhanh
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'Tiệm nào gần đây?',
              'Giá cắt tóc bao nhiêu?',
              'Đặt lịch như thế nào?',
            ].map((hint) => ActionChip(
              label: Text(hint, style: const TextStyle(color: Colors.white70)),
              backgroundColor: const Color(0xFF2A2A2A),
              onPressed: () => vm.sendMessage(hint),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(BuildContext context, ChatViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: vm.inputController,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12,
                ),
              ),
              onSubmitted: (v) => vm.sendMessage(v),
            ),
          ),
          const SizedBox(width: 8),
          // Nút suggest barber
          IconButton(
            onPressed: vm.isSearching
                ? null
                : () => vm.searchBarber(vm.inputController.text),
            icon: vm.isSearching
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.store_mall_directory_outlined,
                color: Colors.amber),
            tooltip: 'Tìm tiệm',
          ),
          // Nút gửi
          IconButton(
            onPressed: vm.isSending
                ? null
                : () => vm.sendMessage(vm.inputController.text),
            icon: vm.isSending
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send_rounded, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}