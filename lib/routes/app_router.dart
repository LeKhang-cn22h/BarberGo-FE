  import 'package:barbergofe/core/utils/intro_service.dart';
import 'package:barbergofe/routes/route_names.dart';
import 'package:barbergofe/routes/shell_routes.dart';
import 'package:barbergofe/views/OTP/page/otp_page.dart';
import 'package:barbergofe/views/auth/SignUp_page.dart';
import 'package:barbergofe/views/detail_shop/detail_shop_page.dart';
import 'package:barbergofe/views/forgotPass/forgotPass_page.dart';
import 'package:barbergofe/views/newPass/newPass_page.dart';
  import 'package:barbergofe/views/not_found_page.dart';
import 'package:barbergofe/views/succes/succes_page.dart';
  import 'package:go_router/go_router.dart';
  import 'package:barbergofe/views/auth/SignIn_page.dart';
  import 'package:barbergofe/views/intro/Screen_intro.dart';
  import 'package:barbergofe/views/acne/acne_camera_view.dart';
  import 'package:barbergofe/viewmodels/acne_viewmodel.dart';
  import 'package:provider/provider.dart';
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
        GoRoute(
            path: RouteNames.otp,
            name: 'OTP',
          builder: (context, state) => const OtpPage()
        ),
        GoRoute(
            path:RouteNames.forgot,
        name: 'forgot',
          builder: (context, state) => const ForgotpassPage()
        ),
        GoRoute(path: RouteNames.succes,
        name: 'succes',
            builder: (context, state) => const SuccesPage()
        ),
        GoRoute(path: RouteNames.newPass,
            name: 'newpass',
            builder: (context, state) => const NewpassPage()
        ),
        GoRoute(
          path: RouteNames.acnes,
          name: 'acne',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => AcneViewModel(),
            child: const AcneCameraView(),
          ),
        ),
        GoRoute(path: RouteNames.detail,
        name: 'detail',
          builder: (context, state) {
          final id = state.pathParameters['id'] ?? "";
          return DetailShopPage(id: id);
  }
        ),

        shellRoutes,
        
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
