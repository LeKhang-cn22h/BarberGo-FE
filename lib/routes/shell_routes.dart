import 'package:barbergofe/models/barber/barber_model.dart';
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
    // ========== HOME ==========
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),

    // ========== BOOKING ==========
    GoRoute(
      path: '/booking',
      name: 'booking',
      pageBuilder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;

        print('=== BOOKING ROUTER DEBUG ===');
        print('Full args: $args');
        print('Keys in args: ${args?.keys}');

        final barber = args?['initialBarber'] as BarberModel?;

        final rawServiceIds = args?['initialServiceIds'];

        print('Barber: ${barber?.name}');
        print('Raw service IDs: $rawServiceIds');
        print('Type: ${rawServiceIds?.runtimeType}');

        // Convert service IDs
        List<String> serviceIds = [];
        if (rawServiceIds != null) {
          if (rawServiceIds is List<int>) {
            serviceIds = rawServiceIds.map((id) => id.toString()).toList();
          } else if (rawServiceIds is List<String>) {
            serviceIds = rawServiceIds;
          } else if (rawServiceIds is List<dynamic>) {
            serviceIds = rawServiceIds.map((id) => id.toString()).toList();
          }
        }

        print('Converted service IDs: $serviceIds');
        print('============================');

        return NoTransitionPage(
          key: state.pageKey,
          child: BookingPage(
            initialBarber: barber,
            initialServiceIds: serviceIds.isNotEmpty ? serviceIds : null,
          ),
        );
      },
    ),

    // ========== HISTORY ==========
    GoRoute(
      path: '/history',
      name: 'history',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const BookingHistoryPage(),
      ),
    ),

    // ========== PROFILE ==========
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ProfilePage(),
      ),
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