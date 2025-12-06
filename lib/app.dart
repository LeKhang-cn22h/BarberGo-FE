import 'package:barbergofe/core/theme/app_theme.dart';
import 'package:barbergofe/routes/app_router.dart';
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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()..init(),

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


