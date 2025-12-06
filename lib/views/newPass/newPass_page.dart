import 'package:barbergofe/views/newPass/widgets/tilte_new_pass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/content_new_pass.dart';

class NewpassPage extends StatelessWidget {
  final String email;
  final String token;

  const NewpassPage({
    Key? key,
    this.email = '',
    this.token = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('[NEWPASS PAGE] Building with:');
    print('   Email: $email');
    print('   Token: ${token.isNotEmpty ? "exists (${token.length} chars)" : "empty"}');

    //  Nếu không có email hoặc token, hiện error screen
    if (email.isEmpty || token.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFD4B5B5),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Link không hợp lệ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Link đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.\nVui lòng yêu cầu link mới.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Back to Forgot Password
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed('forgot');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4B8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Yêu cầu link mới',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Có đủ email và token → Hiện form đổi mật khẩu
    return Scaffold(
      backgroundColor: const Color(0xFFD4B5B5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const TitleNewPass(),

              const SizedBox(height: 40),

              // Content
              Center(
                child: ContentNewPass(
                  email: email,
                  token: token,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}