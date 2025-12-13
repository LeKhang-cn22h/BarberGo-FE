import 'package:barbergofe/core/theme/app_theme.dart';
import 'package:barbergofe/routes/app_router.dart';
import 'package:barbergofe/services/google_auth_service.dart';
import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/viewmodels/booking/booking_history_viewmodel.dart';
import 'package:barbergofe/viewmodels/booking/booking_viewmodel.dart';
import 'package:barbergofe/viewmodels/home/home_viewmodel.dart';
import 'package:barbergofe/viewmodels/profile/profile_viewmodel.dart';
import 'package:barbergofe/viewmodels/service/service_viewmodel.dart';
import 'package:barbergofe/viewmodels/time_slot/time_slot_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  final GoogleAuthService googleAuthService;

  const MyApp({super.key, required this.googleAuthService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider<GoogleAuthService>.value(
        value: googleAuthService,
      ),
      ChangeNotifierProvider(create: (_) => AuthViewModel(googleAuthService: googleAuthService)..init(),

      ),
      ChangeNotifierProvider(
        create: (_) => ProfileViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => AppointmentViewModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => HomeViewModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => BarberViewModel(),
      ),
      ChangeNotifierProvider(create: (context) => ServiceViewModel()),
      ChangeNotifierProvider(create: (_) => BookingViewModel()),
      ChangeNotifierProvider(create: (_) => TimeSlotViewModel()),
      ChangeNotifierProvider(create: (_) => BookingHistoryViewModel()),


    ],
      child:
      MaterialApp.router(
      title: CommonStrings.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.lightTheme,
    )
    );
  }
}


