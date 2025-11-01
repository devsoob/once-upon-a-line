import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const ProfileIcon({super.key, this.onPressed, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(overlayColor: const Color(0xFF222222).withValues(alpha: 0.1)),
      icon: Icon(Icons.person_outline, color: const Color(0xFF222222), size: size),
    );
  }
}
