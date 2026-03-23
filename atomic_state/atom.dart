import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Atom<T> extends ValueNotifier<T> {
  Atom(this._value) : super(_value);

  T _value;

  @override
  T get value => _value;

  @override
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  void emit(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  /// Call the atom directly as a widget.
  /// Only use with Atom<bool>, Atom<String>, or Atom<List>.
  /// Returns [fallback] (default SizedBox()) when value is falsy/empty.
  ///
  /// Usage:
  ///   isSelected((_) => const SelectedIndicator())
  ///   searchQuery((value) => Text(value))
  ///   searchQuery(Text.new)
  Widget call(
    Widget Function(T value) builder, {
    Widget fallback = const SizedBox(),
  }) {
    return ValueListenableBuilder(
      valueListenable: this,
      builder: (_, value, __) {
        if (value is bool) return value ? builder(value) : fallback;
        if (value is String) return value.isNotEmpty ? builder(value) : fallback;
        if (value is List) return value.isNotEmpty ? builder(value) : fallback;
        return fallback;
      },
    );
  }
}
