import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';

class SmartCrmLogo extends StatelessWidget {
  final double size;

  const SmartCrmLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: AppColors.primary, size: size),
            Icon(Icons.bar_chart, color: Colors.green, size: size * 0.7),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
