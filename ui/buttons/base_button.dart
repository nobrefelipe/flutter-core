import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grade_coin/core/ui/text.dart';

import '../_theme.dart';
import 'loading_state_mixin.dart';

enum ButtonType { primary, secondary, destructive, ghost }

enum ButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String label;
  final Future<void> Function()? onTap;
  final ButtonType type;
  final ButtonSize size;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool disabled;
  final bool fullWidth;
  final bool? isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.leftIcon,
    this.rightIcon,
    this.disabled = false,
    this.fullWidth = true,
    this.isLoading,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with LoadingStateMixin {
  bool get _isDisabled => widget.disabled || widget.onTap == null;
  bool get _showLoading => widget.isLoading ?? isLoading.value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, internalLoading, _) {
        final bgColor = _getBgColor(colors);
        final textColor = _getTextColor(colors);
        final textStyle = _getTextStyle(theme).copyWith(color: textColor);
        final height = _getHeight();
        final iconSize = _getFontSize() * 1.4;

        return SizedBox(
          height: height,
          width: widget.fullWidth ? double.infinity : null,
          child: Stack(
            children: [
              Positioned.fill(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: bgColor,
                  disabledColor: colors.surfaceContainerHighest,
                  onPressed: _isDisabled || _showLoading ? null : () => withLoading(widget.onTap!),
                  borderRadius: BorderRadius.circular(DesignTokens.buttonBorderRadius),
                  child: Row(
                    mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.leftIcon != null) ...[widget.leftIcon!, const SizedBox(width: 8)],
                      UIKText.body(widget.label),
                      if (widget.rightIcon != null) ...[const SizedBox(width: 8), widget.rightIcon!],
                    ],
                  ),
                ),
              ),
              if (_showLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: bgColor.withOpacity(0.7), borderRadius: BorderRadius.circular(DesignTokens.buttonBorderRadius)),
                    child: loadingWidget(20),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getBgColor(ColorScheme colors) {
    if (_isDisabled) return colors.surfaceContainerHighest;
    return switch (widget.type) {
      ButtonType.primary => colors.primary,
      ButtonType.secondary => colors.surface,
      ButtonType.destructive => colors.error,
      ButtonType.ghost => Colors.transparent,
    };
  }

  Color _getTextColor(ColorScheme colors) {
    if (_isDisabled) return colors.onSurface.withOpacity(0.38);
    return switch (widget.type) {
      ButtonType.primary => colors.onPrimary,
      ButtonType.secondary => colors.primary,
      ButtonType.destructive => colors.onError,
      ButtonType.ghost => colors.primary,
    };
  }

  double _getHeight() => switch (widget.size) {
    ButtonSize.small => DesignTokens.buttonSmallHeight,
    ButtonSize.medium => DesignTokens.buttonMediumHeight,
    ButtonSize.large => DesignTokens.buttonLargeHeight,
  };

  double _getFontSize() => switch (widget.size) {
    ButtonSize.small => DesignTokens.buttonSmallFontSize,
    ButtonSize.medium => DesignTokens.buttonMediumFontSize,
    ButtonSize.large => DesignTokens.buttonLargeFontSize,
  };

  TextStyle _getTextStyle(ThemeData theme) => switch (widget.size) {
    ButtonSize.small => theme.buttonSmallStyle,
    ButtonSize.medium => theme.buttonMediumStyle,
    ButtonSize.large => theme.buttonLargeStyle,
  };
}
