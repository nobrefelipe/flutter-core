import 'package:flutter/material.dart';

import '../buttons/ui_kit_button.dart';
import '../text.dart';
import 'bottom_sheet_action.dart';
import 'bottom_sheet_close_button.dart';
import 'gradient_fade.dart';

/// The standard shell for all bottom sheets.
///
/// Footer priority (mutually exclusive):
///   1. [footer]           — fully custom widget
///   2. [primaryAction]    — single CTA button
///      + [secondaryAction] — optional cancel button below the primary
///   3. nothing            — content only, no footer
///
/// Scroll behaviour:
///   Content scrolls only when it overflows the available height.
///   GradientFade is shown automatically when content is scrollable.
class BottomSheetShell extends StatelessWidget {
  final String title;
  final Widget content;

  // Footer options — at most one of [footer] or [primaryAction] should be set
  final Widget? footer;
  final BottomSheetAction? primaryAction;
  final BottomSheetAction? secondaryAction;

  const BottomSheetShell({
    super.key,
    required this.title,
    required this.content,
    this.footer,
    this.primaryAction,
    this.secondaryAction,
  }) : assert(
         footer == null || primaryAction == null,
         'Provide either a custom footer or a primaryAction, not both.',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: title),
          const SizedBox(height: 20),
          _ScrollableBody(content: content),
          if (_hasFooter) ...[
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ],
      ),
    );
  }

  bool get _hasFooter => footer != null || primaryAction != null;

  Widget _buildFooter() {
    if (footer != null) return footer!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (primaryAction != null)
          UIKButton.primary(
            label: primaryAction!.label,
            onTap: primaryAction!.onTap,
          ),
        if (secondaryAction != null) ...[
          const SizedBox(height: 10),
          UIKButton.ghost(
            label: secondaryAction!.label,
            onTap: secondaryAction!.onTap,
          ),
        ],
      ],
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: UIKText.h5(title),
          ),
        ),
        const BottomSheetCloseButton(),
      ],
    );
  }
}

// ─── Auto-scroll body ────────────────────────────────────────────────────────

class _ScrollableBody extends StatefulWidget {
  final Widget content;
  const _ScrollableBody({required this.content});

  @override
  State<_ScrollableBody> createState() => _ScrollableBodyState();
}

class _ScrollableBodyState extends State<_ScrollableBody> {
  // Max height for the scrollable region before it kicks in.
  // 60% of screen height feels natural for most sheets.
  static const double _maxBodyHeight = 0.60;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * _maxBodyHeight;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _OverflowDetector(
            maxHeight: constraints.maxHeight,
            builder: (context, isOverflowing) {
              final scrollable = SingleChildScrollView(
                physics: isOverflowing ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                child: widget.content,
              );

              if (!isOverflowing) return scrollable;

              return GradientFade(
                fadeTop: false, // only fade the bottom edge
                fadeBottom: true,
                child: scrollable,
              );
            },
          );
        },
      ),
    );
  }
}

/// Renders content invisibly first to measure its natural height,
/// then reports whether it overflows the given [maxHeight].
class _OverflowDetector extends StatefulWidget {
  final double maxHeight;
  final Widget Function(BuildContext context, bool isOverflowing) builder;

  const _OverflowDetector({
    required this.maxHeight,
    required this.builder,
  });

  @override
  State<_OverflowDetector> createState() => _OverflowDetectorState();
}

class _OverflowDetectorState extends State<_OverflowDetector> {
  bool? _isOverflowing;

  @override
  Widget build(BuildContext context) {
    if (_isOverflowing == null) {
      // First pass: measure content height with an invisible render
      return OverflowBox(
        minHeight: 0,
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                setState(() {
                  _isOverflowing = renderBox.size.height > widget.maxHeight;
                });
              }
            });
            return widget.builder(context, false);
          },
        ),
      );
    }

    return widget.builder(context, _isOverflowing!);
  }
}
