import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:barbergofe/views/Barbers/Areas_page.dart';
import 'package:barbergofe/views/Barbers/Barbers_page.dart';
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
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      print('[ROUTER] Checking redirect for: ${state.uri.path}');

      final hasSeenIntro = await AuthStorage.hasSeenIntro();
      final isLoggedIn = await AuthStorage.isLoggedIn();

      print('   Has seen intro: $hasSeenIntro');
      print('   Is logged in: $isLoggedIn');

      final currentPath = state.uri.path;

      final publicRoutes = [
        RouteNames.getStarted,
        RouteNames.signin,
        RouteNames.signup,
        RouteNames.forgot,
        RouteNames.newPass,
        RouteNames.succes,
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      if (!hasSeenIntro && currentPath != RouteNames.getStarted) {
        print('   → Redirect to intro');
        return RouteNames.getStarted;
      }

      if (hasSeenIntro && !isLoggedIn && currentPath == RouteNames.getStarted) {
        print('   → Redirect to sign in');
        return RouteNames.signin;
      }

      if (isLoggedIn && _isAuthPage(currentPath)) {
        print('   → Already logged in, redirect to home');
        return RouteNames.home;
      }

      if (!isLoggedIn && !isPublicRoute && _isProtectedPage(currentPath)) {
        print('   → Not logged in, redirect to sign in');
        return RouteNames.signin;
      }

      print('   → No redirect');
      return null;
    },

    routes: [
      // ==================== AUTH ROUTES ====================
      GoRoute(
        path: RouteNames.getStarted,
        name: 'intro',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const IntroScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.signin,
        name: 'signin',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignInPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignupPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.forgot,
        name: 'forgot',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotpassPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.newPass,
        name: 'newpass',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';

          return MaterialPage(
            key: state.pageKey,
            child: NewpassPage(email: email, token: token),
          );
        },
      ),

      GoRoute(
        path: RouteNames.succes,
        name: 'succes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SuccesPage(),
        ),
      ),

      // ==================== FEATURE ROUTES ====================
      GoRoute(
        path: RouteNames.acnes,
        name: 'acne',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: ChangeNotifierProvider(
            create: (_) => AcneViewModel(),
            child: const AcneCameraView(),
          ),
        ),
      ),

      GoRoute(
        path: RouteNames.hair,
        name: 'hair',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: CameraScreen(),
        ),
      ),

      // ==================== BARBER ROUTES ====================

      // 1. List Areas
      GoRoute(
        path: RouteNames.ListArea,
        name: 'ListArea',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AreasPage(),
        ),
      ),

      // 2. List Barbers by Area
      GoRoute(
        path: RouteNames.Barbers,  // '/Barbers'
        name: 'Barbers',
        pageBuilder: (context, state) {
          final area = state.extra as String?;

          return MaterialPage(
            key: state.pageKey,
            child: area != null
                ? BarbersPage(area: area)
                : Scaffold(
              appBar: AppBar(title: Text('Error')),
              body: Center(child: Text('Missing area parameter')),
            ),
          );
        },
      ),

      // 3. Barber Detail (with path parameter)
      GoRoute(
        path: RouteNames.detail,  // '/detail/:id'
        name: 'detail',
        pageBuilder: (context, state) {
          final barberId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          final selectedServiceIds = (extra?['selectedServiceIds'] as List<String>?) ?? [];

          return MaterialPage(
            key: state.pageKey,  // QUAN TRỌNG
            child: DetailShopPage(
              id: barberId,
              selectedServiceIds: selectedServiceIds,
            ),
          );
        },
      ),

      GoRoute(
        path: '/service-selection',
        name: 'service-selection',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return MaterialPage(
            key: state.pageKey,
            child: ServiceSelectionPage(
              barberId: args?['barberId'] as String,
              selectedServiceIds: (args?['selectedServiceIds'] as List<dynamic>?)
                  ?.map((id) => id as int)
                  .toList() ?? [],
            ),
          );
        },
      ),

      // ==================== PROFILE ROUTES ====================
      GoRoute(
        path: RouteNames.personal,
        name: 'personal',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PersonalInfoPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.changePass,
        name: 'changePass',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ChangePasswordPage(),
        ),
      ),

      GoRoute(
        path: RouteNames.locationPicker,
        name: 'location_picker',
        pageBuilder: (context, state) {
          final lat = state.uri.queryParameters['lat'];
          final lng = state.uri.queryParameters['lng'];
          final address = state.uri.queryParameters['address'];

          return MaterialPage(
            key: state.pageKey,
            child: LocationPickerPage(
              initialLat: lat != null ? double.tryParse(lat) : null,
              initialLng: lng != null ? double.tryParse(lng) : null,
              initialAddress: address,
            ),
          );
        },
      ),

      GoRoute(
        path: RouteNames.Partneregistration,
        name: 'Partneregistration',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PartnerRegistrationScreen(),
        ),
      ),

      GoRoute(
        path: RouteNames.PartnerSignUpForm,
        name: 'PartnerSignUpForm',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PartnerSignUpFormScreenV2(),
        ),
      ),

      GoRoute(
        path: '/AppointmentDetail',
        name: 'AppointmentDetail',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AppointmentDetailScreen(),
        ),
      ),

      // ==================== SHELL ROUTES ====================
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