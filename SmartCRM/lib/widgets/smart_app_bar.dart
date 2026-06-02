import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class SmartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showProfile;
  final VoidCallback? onProfileTap;

  const SmartAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.showProfile = true,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: showProfile
          ? [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: onProfileTap,
              ),
            ]
          : null,
    );
  }
}

class SmartHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;

  const SmartHomeAppBar({super.key, required this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 28),
          const SizedBox(width: 6),
          const Icon(Icons.bar_chart, color: Colors.lightGreenAccent, size: 22),
          const SizedBox(width: 8),
          const Text(
            'SmartCRM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: onLogout,
        ),
      ],
    );
  }
}
