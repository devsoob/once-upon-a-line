import 'package:flutter/material.dart';
import 'package:once_upon_a_line/core/design_system/colors.dart';

class ProfileIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const ProfileIcon({super.key, this.onPressed, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(overlayColor: AppColors.primary.withValues(alpha: 0.1)),
      icon: Icon(Icons.person_outline, color: AppColors.primary, size: size),
    );
  }
}
