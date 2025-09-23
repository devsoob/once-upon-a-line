import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _timer?.cancel();
    _entry?.remove();

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    _entry = OverlayEntry(
      builder: (BuildContext context) {
        return _ToastBanner(
          message: message,
          duration: duration,
          onDismissed: () {
            _entry?.remove();
            _entry = null;
            _timer = null;
          },
        );
      },
    );

    overlay.insert(_entry!);
  }
}

class _ToastBanner extends StatefulWidget {
  const _ToastBanner({required this.message, required this.duration, required this.onDismissed});

  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // Play in
    _controller.forward();

    // Schedule dismissal
    _dismissTimer = Timer(widget.duration, () async {
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 16 + viewPadding.bottom,
      child: IgnorePointer(
        ignoring: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
