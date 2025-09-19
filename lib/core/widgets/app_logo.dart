import 'package:flutter/material.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double? width;

  const AppLogo({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    final double size = width ?? 24;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BookLogoPainter(size: size)),
    );
  }
}

class _BookLogoPainter extends CustomPainter {
  _BookLogoPainter({required this.size});

  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = AppColors.primary
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final double w = canvasSize.width;
    final double h = canvasSize.height;

    // Match splash screen proportions
    final Rect outerRect = Rect.fromLTWH(w * 0.266, h * 0.24, w * 0.468, h * 0.52);
    final RRect outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(w * 0.055));

    // Left inner vertical line (moved slightly right for better spacing)
    final double leftLineX = w * (200 / 512);
    final double topY = h * (124 / 512);
    final double bottomY = h * (388 / 512);

    // Text guide lines (moved further right for better spacing)
    final double line1StartX = w * (220 / 512);
    final double line1EndX = w * (328 / 512);
    final double line1Y = h * (190 / 512);

    final double line2StartX = w * (220 / 512);
    final double line2EndX = w * (312 / 512);
    final double line2Y = h * (250 / 512);

    final Path path =
        Path()
          ..addRRect(outerRRect)
          ..moveTo(leftLineX, topY)
          ..lineTo(leftLineX, bottomY)
          ..moveTo(line1StartX, line1Y)
          ..lineTo(line1EndX, line1Y)
          ..moveTo(line2StartX, line2Y)
          ..lineTo(line2EndX, line2Y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BookLogoPainter oldDelegate) {
    return oldDelegate.size != size;
  }
}
