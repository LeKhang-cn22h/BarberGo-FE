import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerMainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const OwnerMainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppTextStyles.headinglight,),
        centerTitle: true,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        currentIndex: _getIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('owner_home');
              break;
            case 1:
              context.goNamed('owner_booking');
              break;
            case 2:
              context.goNamed('owner_history');
              break;
            case 3:
              context.goNamed('owner_profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
    );
  }

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/owner_booking')) return 1;
    if (location.startsWith('/owner_history')) return 2;
    if (location.startsWith('/owner_profile')) return 3;

    return 0; // default là home
  }
}
