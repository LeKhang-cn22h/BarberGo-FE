import 'package:barbergofe/views/booking/booking_page.dart';
import 'package:barbergofe/views/history/history_page.dart';
import 'package:barbergofe/views/home/home_page.dart';
import 'package:barbergofe/views/main_layout/main_layout.dart';
import 'package:barbergofe/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
/// ShellRoute dùng cho layout có Bottom Navigation
final ShellRoute shellRoutes = ShellRoute(
  builder: (context, state, child) {
    String title = _getTitle(state.uri.toString());

    return MainLayout(
      title: title,
      child: child,
    );
  },

  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    // GoRoute(
    //   path: '/booking',
    //   name: 'booking',
    //   builder: (context, state) => const BookingPage(),
    // ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const BookingHistoryPage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);

String _getTitle(String location) {
  if (location.startsWith('/home')) return 'Trang chủ';
  if (location.startsWith('/booking')) return 'Lịch hẹn';
  if (location.startsWith('/history')) return 'Lịch sử';
  if (location.startsWith('/profile')) return 'Cá nhân';

  return '';
}
