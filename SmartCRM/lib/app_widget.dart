import 'package:flutter/material.dart';

import 'config/app_colors.dart';
import 'core/session/app_session.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

class SmartCrmApp extends StatelessWidget {
  const SmartCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: AppSession.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
