import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/views/main_layout/owner_main_layout.dart';
import 'package:barbergofe/views/ownerBooking/owner_booking_page.dart';
import 'package:barbergofe/views/ownerHistory/owner_history_page.dart';
import 'package:barbergofe/views/ownerHome/owner_home_page.dart';
import 'package:barbergofe/views/ownerProfile/owner_profile_page.dart';
import 'package:barbergofe/views/profile/profile_page.dart';
import 'package:go_router/go_router.dart';

/// ShellRoute dùng cho layout có Bottom Navigation
final ShellRoute ownershellRoutes = ShellRoute(
  builder: (context, state, child) {
    String title = _getTitle(state.uri.toString());

    return OwnerMainLayout(
      title: title,
      child: child,
    );
  },

  routes: [
    // ========== HOME ==========
    GoRoute(
      path: '/owner_home',
      name: 'owner_home',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const OwnerHomePage(),
      ),
    ),

    // ========== BOOKING ==========
    GoRoute(
      path: '/owner_booking',
      name: 'owner_booking',
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
          child: OwnerBookingPage(),
        );
      },
    ),

    // ========== HISTORY ==========
    GoRoute(
      path: '/owner_history',
      name: 'owner_history',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const OwnerHistoryPage(),
      ),
    ),

    // ========== PROFILE ==========
    GoRoute(
      path: '/owner_profile',
      name: 'owner_profile',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const OwnerProfilePage(),
      ),
    ),
  ],
);

String _getTitle(String location) {
  if (location.startsWith('/owner_home')) return 'Trang chủ';
  if (location.startsWith('/owner_booking')) return 'Lịch hẹn';
  if (location.startsWith('/owner_history')) return 'Lịch sử';
  if (location.startsWith('/owner_profile')) return 'Cá nhân';
  return '';
}