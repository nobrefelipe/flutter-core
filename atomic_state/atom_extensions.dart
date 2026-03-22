import 'package:flutter/material.dart';

extension AtomExtensions<T> on ValueNotifier<T> {
  /// Rebuilds when the value changes. Always renders the returned widget.
  /// Use for Result<T>, sealed classes, and custom types.
  Widget watch(Widget Function(T) builder) {
    return ValueListenableBuilder(
      valueListenable: this,
      builder: (_, value, __) => builder(value),
    );
  }

  /// Rebuilds when the value changes, but only renders [builder] if the value
  /// is considered "truthy". Otherwise renders [fallback] (default: SizedBox()).
  ///
  /// Truthy rules:
  ///   - bool     → true
  ///   - String   → not empty
  ///   - List     → not empty
  ///
  /// Only use with Atom<bool>, Atom<String>, or Atom<List>.
  /// For Result<T> or custom types always use watch() instead.
  Widget watchIf(
    Widget Function(T) builder, {
    Widget fallback = const SizedBox(),
  }) {
    assert(
      T == bool || T == String || _isList<T>(),
      'watchIf() should only be used with Atom<bool>, Atom<String>, or Atom<List>. '
      'For Result<T> or custom types use watch() instead.',
    );

    return ValueListenableBuilder(
      valueListenable: this,
      builder: (_, value, __) {
        if (value is bool) {
          return value ? builder(value) : fallback;
        }
        if (value is String) {
          return value.isNotEmpty ? builder(value) : fallback;
        }
        if (value is List) {
          return value.isNotEmpty ? builder(value) : fallback;
        }
        // Should never reach here due to assert above
        return fallback;
      },
    );
  }
}

bool _isList<T>() => <T>[] is List;
