import 'dart:async';
import 'dart:ui' show PathMetric, PathMetrics;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';
import 'package:once_upon_a_line/app/data/utils/nickname_generator.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';
import 'package:once_upon_a_line/app/data/services/user_session_service.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _initializeSession();

    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      context.goNamed(homeRouteName);
    });
  }

  Future<void> _initializeSession() async {
    final UserSessionService sessionService = GetIt.I<UserSessionService>();
    final bool hasSession = await sessionService.hasSession();

    if (!hasSession) {
      // Generate random nickname and create user session
      final String randomNickname = NicknameGenerator.generateRandomNickname();
      final String userId = const Uuid().v4();

      final UserSession newSession = UserSession(
        userId: userId,
        nickname: randomNickname,
        lastWriteAt: DateTime.now(),
      );

      await sessionService.saveSession(newSession);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(gradient: AppColors.splashGradient),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(painter: _LogoBookPainter(progress: _progress.value)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoBookPainter extends CustomPainter {
  _LogoBookPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..color = Colors.white
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Match SVG proportions: outer rounded rect inset and rx ~ 22 relative
    final Rect outerRect = Rect.fromLTWH(w * 0.266, h * 0.24, w * 0.468, h * 0.52);
    final RRect outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(w * 0.055));

    // Left inner vertical line (similar to x=172 in 512 viewBox) but slightly shifted right
    final double leftLineX = w * (178 / 512);
    final double topY = h * (124 / 512);
    final double bottomY = h * (388 / 512);

    // Text guide lines
    final double line1StartX = w * (196 / 512);
    final double line1EndX = w * (328 / 512);
    final double line1Y = h * (204 / 512);

    final double line2StartX = w * (196 / 512);
    final double line2EndX = w * (312 / 512);
    final double line2Y = h * (240 / 512);

    final Path path =
        Path()
          ..addRRect(outerRRect)
          ..moveTo(leftLineX, topY)
          ..lineTo(leftLineX, bottomY)
          ..moveTo(line1StartX, line1Y)
          ..lineTo(line1EndX, line1Y)
          ..moveTo(line2StartX, line2Y)
          ..lineTo(line2EndX, line2Y);

    // Animate stroke drawing
    final PathMetrics metrics = path.computeMetrics(forceClosed: false);
    final Path animated = Path();
    for (final PathMetric metric in metrics) {
      final double len = metric.length * progress.clamp(0.0, 1.0);
      if (len > 0) {
        animated.addPath(metric.extractPath(0, len), Offset.zero);
      }
    }

    canvas.drawPath(animated, paint);
  }

  @override
  bool shouldRepaint(covariant _LogoBookPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
