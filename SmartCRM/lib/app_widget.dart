import 'package:flutter/material.dart';

import 'config/app_colors.dart';
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
      home: const LoginScreen(),
    );
  }
}
