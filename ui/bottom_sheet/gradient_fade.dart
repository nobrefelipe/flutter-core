import 'package:flutter/material.dart';

/// Applies a top and/or bottom gradient fade over a child widget.
/// Color defaults to the theme's surface color so it works in light and dark mode.
class GradientFade extends StatelessWidget {
  final Widget child;
  final double fadeHeight;
  final Color? color; // if null, uses Theme.of(context).colorScheme.surface
  final bool fadeTop;
  final bool fadeBottom;

  const GradientFade({
    super.key,
    required this.child,
    this.fadeHeight = 32,
    this.color,
    this.fadeTop = true,
    this.fadeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final fadeColor = color ?? Theme.of(context).colorScheme.surface;

    return Stack(
      children: [
        child,
        if (fadeTop)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: fadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [fadeColor, fadeColor.withValues(alpha: 0.0)],
                  ),
                ),
              ),
            ),
          ),
        if (fadeBottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: fadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [fadeColor, fadeColor.withValues(alpha: 0.0)],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
