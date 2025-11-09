  import 'package:barbergofe/core/utils/intro_service.dart';
import 'package:barbergofe/routes/route_names.dart';
import 'package:barbergofe/views/auth/SignUp_page.dart';
  import 'package:barbergofe/views/not_found_page.dart';
  import 'package:go_router/go_router.dart';
  import 'package:barbergofe/views/auth/SignIn_page.dart';
  import 'package:barbergofe/views/intro/Screen_intro.dart';
  final GoRouter appRouter = GoRouter(
      initialLocation: RouteNames.getStarted,
      routes:[
        GoRoute(
            path:RouteNames.signin,
            name: 'signin',
            builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/',
          name: 'intro',
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
          path: RouteNames.signup,
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
      ],   errorBuilder: (context, state) => const NotFoundPage(),
      redirect: (context, state) async {
        bool seen = await IntroService.isIntroSeen();

        // Nếu chưa xem intro, chuyển đến trang intro
        if (!seen && state.uri.toString() != RouteNames.getStarted) {
          return RouteNames.getStarted;
        }

        // Nếu đã xem intro, không redirect, giữ nguyên route
        return null;
      }

  );
