import 'package:flutter/material.dart';

import '../config/app_strings.dart';

class OfflineBanner extends StatelessWidget {
  final bool visible;

  const OfflineBanner({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Text(
        AppStrings.dadosOffline,
        style: TextStyle(color: Colors.black87, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}
