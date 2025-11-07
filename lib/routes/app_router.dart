import 'package:barbergofe/routes/route_names.dart';
import 'package:barbergofe/views/not_found_page.dart';
import 'package:go_router/go_router.dart';
import 'package:barbergofe/views/auth/login_page.dart';
final GoRouter appRouter = GoRouter(
    initialLocation: RouteNames.login,
    routes:[
      GoRoute(
          path:RouteNames.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
      ),
    ],   errorBuilder: (context, state) => const NotFoundPage(),


);
