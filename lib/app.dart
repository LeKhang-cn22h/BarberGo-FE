import 'package:barbergofe/core/theme/app_theme.dart';
import 'package:barbergofe/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/core/constants/app_strings.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
    );
  }
}


