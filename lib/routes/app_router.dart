// lib/routes/app_router.dart

import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:barbergofe/views/Barbers/Areas_page.dart';
import 'package:barbergofe/views/booking/booking_page.dart';
import 'package:barbergofe/views/booking/service_selection_page.dart';
import 'package:barbergofe/views/location/location_picker_page.dart';
import 'package:barbergofe/views/profile/PartnerSignUpForm.dart';
import 'package:barbergofe/views/profile/appointment_detail_page.dart';
import 'package:barbergofe/views/profile/change_password_page.dart';
import 'package:barbergofe/views/profile/partner_registration_page.dart';
import 'package:barbergofe/views/profile/personal_info_page..dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/routes/route_names.dart';
import 'package:barbergofe/routes/shell_routes.dart';

import 'package:barbergofe/views/intro/Screen_intro.dart';
import 'package:barbergofe/views/auth/SignIn_page.dart';
import 'package:barbergofe/views/auth/SignUp_page.dart';
import 'package:barbergofe/views/OTP/page/otp_page.dart';
import 'package:barbergofe/views/forgotPass/forgotPass_page.dart';
import 'package:barbergofe/views/hair/hairstyle_screen.dart';
import 'package:barbergofe/views/newPass/newPass_page.dart';
import 'package:barbergofe/views/succes/succes_page.dart';
import 'package:barbergofe/views/not_found_page.dart';

import 'package:barbergofe/views/detail_shop/detail_shop_page.dart';
import 'package:barbergofe/views/acne/acne_camera_view.dart';
import 'package:barbergofe/viewmodels/acne_viewmodel.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.getStarted,

    // ==================== REDIRECT LOGIC ====================
    redirect: (context, state) async {
      print('[ROUTER] Checking redirect for: ${state.uri.path}');

      final hasSeenIntro = await AuthStorage.hasSeenIntro();
      final isLoggedIn = await AuthStorage.isLoggedIn();

      print('   Has seen intro: $hasSeenIntro');
      print('   Is logged in: $isLoggedIn');

      final currentPath = state.uri.path;

      // ==================== PUBLIC ROUTES (Không cần auth) ====================
      final publicRoutes = [
        RouteNames.getStarted,
        RouteNames.signin,
        RouteNames.signup,
        RouteNames.forgot,
        RouteNames.newPass,
        RouteNames.succes,
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      // ==================== INTRO CHECK ====================

      // 1. Chưa xem intro → vào intro
      if (!hasSeenIntro && currentPath != RouteNames.getStarted) {
        print('   → Redirect to intro');
        return RouteNames.getStarted;
      }

      // 2. Đã xem + chưa login + đang ở intro → chuyển login
      if (hasSeenIntro && !isLoggedIn && currentPath == RouteNames.getStarted) {
        print('   → Redirect to sign in');
        return RouteNames.signin;
      }

      // ==================== AUTH CHECK ====================

      // 3. Đã login → không cho vào trang auth (trừ newPass và succes)
      if (isLoggedIn && _isAuthPage(currentPath)) {
        print('   → Already logged in, redirect to home');
        return RouteNames.home;
      }

      // 4. Chưa login + không phải public route → redirect login
      if (!isLoggedIn && !isPublicRoute && _isProtectedPage(currentPath)) {
        print('   → Not logged in, redirect to sign in');
        return RouteNames.signin;
      }

      print('   → No redirect');
      return null;
    },

    // ==================== ROUTES ====================
    routes: [
      GoRoute(
        path: RouteNames.getStarted,
        name: 'intro',
        builder: (context, state) => const IntroScreen(),
      ),

      GoRoute(
        path: RouteNames.signin,
        name: 'signin',
        builder: (context, state) => const SignInPage(),
      ),

      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),

      // GoRoute(
      //   path: RouteNames.otp,
      //   name: 'otp',
      //   builder: (context, state) => const OtpPage(),
      // ),

      GoRoute(
        path: RouteNames.forgot,
        name: 'forgot',
        builder: (context, state) => const ForgotpassPage(),
      ),

      // ==================== RESET PASSWORD ====================
      GoRoute(
        path: RouteNames.newPass,
        name: 'newpass',
        builder: (context, state) {
          print(' [ROUTER] Building NewPass page');
          print('   URI: ${state.uri}');
          print('   Query params: ${state.uri.queryParameters}');

          // Get parameters from URL query
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';

          print('   Email: $email');
          print('   Token: ${token.isNotEmpty ? "exists (${token.length} chars)" : "empty"}');

          // ✅ BỎ CHECK TOKEN Ở ĐÂY
          // Để NewpassPage tự handle việc hiển thị error
          return NewpassPage(
            email: email,
            token: token,
          );
        },
      ),

      GoRoute(
        path: RouteNames.succes,
        name: 'succes',
        builder: (context, state) => const SuccesPage(),
      ),

      GoRoute(
        path: RouteNames.acnes,
        name: 'acne',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => AcneViewModel(),
          child: const AcneCameraView(),
        ),
      ),

      GoRoute(
        path: RouteNames.detail,
        name: 'detail',
        builder: (context, state) {
          final extra =state.extra as Map<String, dynamic>?;
          final barberId=state.pathParameters['id'].toString();

           final selectedServiceIds=(extra?['selectedServiceIds'] as List<String>?) ?? [];
          return DetailShopPage(id: barberId, selectedServiceIds: selectedServiceIds);
        },
      ),

      GoRoute(
        path: RouteNames.personal,
        name: 'personal',
        builder: (context, state) => const PersonalInfoPage(),
      ),

      GoRoute(
        path: RouteNames.changePass,
        name: 'changePass',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: RouteNames.locationPicker,
        name: 'location_picker',
        builder: (context, state) {
          // Get optional initial position
          final lat = state.uri.queryParameters['lat'];
          final lng = state.uri.queryParameters['lng'];
          final address = state.uri.queryParameters['address'];

          return LocationPickerPage(
            initialLat: lat != null ? double.tryParse(lat) : null,
            initialLng: lng != null ? double.tryParse(lng) : null,
            initialAddress: address,
          );
        },
      ),
      GoRoute(
          path: RouteNames.Partneregistration,
          name: 'Partneregistration',
          builder: (context, state) => const PartnerRegistrationScreen()
      ),
      GoRoute(
          path: RouteNames.PartnerSignUpForm,
          name: 'PartnerSignUpForm',
          builder: (context, state) => const PartnerSignUpFormScreenV2()
      ),
      GoRoute(
          path: '/AppointmentDetail', // ← THÊM :appointmentId
          name: 'AppointmentDetail',
          builder: (context, state) {
            return AppointmentDetailScreen();
          }
      ),
      // Trong router configuration
      GoRoute(
        path: '/service-selection',
        name: 'service-selection',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return ServiceSelectionPage(
            barberId: args?['barberId'] as String,
            selectedServiceIds: (args?['selectedServiceIds'] as List<dynamic>?)
                ?.map((id) => id as int)
                .toList() ?? [],
          );
        },
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          // Chuyển đổi serviceIds thành List<String>
          List<String> serviceIds = [];

          if (args?['serviceIds'] != null) {
            final dynamic rawIds = args!['serviceIds'];
            if (rawIds is List<int>) {
              // Nếu là List<int>, chuyển sang List<String>
              serviceIds = rawIds.map((id) => id.toString()).toList();
            } else if (rawIds is List<String>) {
              // Nếu đã là List<String>, giữ nguyên
              serviceIds = rawIds;
            } else if (rawIds is List<dynamic>) {
              // Nếu là List<dynamic>, chuyển sang String
              serviceIds = rawIds.map((id) => id.toString()).toList();
            }
          }

          print('=== ROUTER DEBUG ===');
          print('Raw serviceIds: ${args?['serviceIds']}');
          print('Type: ${args?['serviceIds']?.runtimeType}');
          print('Converted to String: $serviceIds');

          return BookingPage(
            initialBarber: args?['barber'] as BarberModel?,
            initialServiceIds: serviceIds, // Luôn là List<String>
          );
        },
      ),

        GoRoute(path: RouteNames.hair,
            name: 'hair',
            builder: (context, state) =>  CameraScreen()
        ),
      GoRoute(path: RouteNames.ListArea,
      name: 'ListArea',
          builder: (context, state) =>  AreasPage(),

      ),

      shellRoutes,
    ],

    errorBuilder: (context, state) => const NotFoundPage(),
  );

  // ==================== HELPERS ====================

  static bool _isAuthPage(String path) {
    return path == RouteNames.signin ||
        path == RouteNames.signup ||
        path == RouteNames.otp ||
        path == RouteNames.forgot ||
        path == RouteNames.getStarted;
  }

  static bool _isProtectedPage(String path) {
    return path == RouteNames.home ||
        path == RouteNames.acnes ||
        path.startsWith('/detail/');
  }
}