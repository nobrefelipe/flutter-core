import 'package:flutter/material.dart';
import 'base_button.dart';

/// Fluent facade over AppButton.
/// Usage:
///   UIKButton.primary.large(label: 'Save', onTap: () async => save())
///   UIKButton.destructive.small(label: 'Delete', onTap: () async => delete())
///   UIKButton.primary(label: 'Default medium', onTap: () async => go())
class UIKButton {
  static final primary = _ButtonFactory(ButtonType.primary);
  static final secondary = _ButtonFactory(ButtonType.secondary);
  static final destructive = _ButtonFactory(ButtonType.destructive);
  static final ghost = _ButtonFactory(ButtonType.ghost);
}

class _ButtonFactory {
  final ButtonType _type;
  _ButtonFactory(this._type);

  // Default call — medium size
  Widget call({
    required String label,
    required Future<void> Function()? onTap,
    Widget? leftIcon,
    Widget? rightIcon,
    bool disabled = false,
    bool fullWidth = true,
    bool? isLoading,
  }) => _build(
    label: label,
    onTap: onTap,
    size: ButtonSize.medium,
    leftIcon: leftIcon,
    rightIcon: rightIcon,
    disabled: disabled,
    fullWidth: fullWidth,
    isLoading: isLoading,
  );

  // Explicit size accessors
  late final small = _SizeFactory(_type, ButtonSize.small);
  late final medium = _SizeFactory(_type, ButtonSize.medium);
  late final large = _SizeFactory(_type, ButtonSize.large);

  Widget _build({
    required String label,
    required Future<void> Function()? onTap,
    required ButtonSize size,
    Widget? leftIcon,
    Widget? rightIcon,
    bool disabled = false,
    bool fullWidth = true,
    bool? isLoading,
  }) => AppButton(
    label: label,
    onTap: onTap,
    type: _type,
    size: size,
    leftIcon: leftIcon,
    rightIcon: rightIcon,
    disabled: disabled,
    fullWidth: fullWidth,
    isLoading: isLoading,
  );
}

class _SizeFactory {
  final ButtonType _type;
  final ButtonSize _size;
  const _SizeFactory(this._type, this._size);

  Widget call({
    required String label,
    required Future<void> Function()? onTap,
    Widget? leftIcon,
    Widget? rightIcon,
    bool disabled = false,
    bool fullWidth = true,
    bool? isLoading,
  }) => AppButton(
    label: label,
    onTap: onTap,
    type: _type,
    size: _size,
    leftIcon: leftIcon,
    rightIcon: rightIcon,
    disabled: disabled,
    fullWidth: fullWidth,
    isLoading: isLoading,
  );
}
