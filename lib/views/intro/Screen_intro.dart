import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/button_styles.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/viewmodels/intro/intro_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'widgets/intro_content.dart';
import 'widgets/intro_indicator.dart';

// Màn hình Intro gồm nhiều slide hướng dẫn người dùng
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntroViewModel(),
      child: Consumer<IntroViewModel>(
        builder: (context, viewModel, _) {
          final introList = viewModel.introList;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // --- PHẦN PAGEVIEW (slide intro) ---
                  Expanded(
                    flex: 4,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: introList.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final intro = introList[index];
                        return IntroContent(model: intro);
                      },
                    ),
                  ),

                  // --- NÚT HÀNH ĐỘNG (Next / Bắt đầu) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      style: AppButtonStyles.roundedButtonBold,
                      onPressed: () {
                        if (_currentPage < introList.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Gọi hàm onGet để lưu trạng thái đã xem Intro
                           viewModel.onGet();

                          // Chuyển sang Login Screen
                          context.pushNamed('signup');
                        }
                      },
                      child: Text(
                        introList[_currentPage].textbtn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // --- PHẦN CHẤM TRÒN (indicator) ---
                  IntroIndicator(
                    itemCount: introList.length,
                    currentIndex: _currentPage,
                  ),



                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
