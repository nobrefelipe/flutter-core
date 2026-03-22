import 'package:flutter/material.dart';

/// Wraps a widget so tapping anywhere outside a text field dismisses the keyboard.
/// Wrap around the Scaffold body or the entire Scaffold.
final isKeyboardOpened = ValueNotifier(false);

class RemoveFocusOnTap extends StatelessWidget {
  final Widget child;

  const RemoveFocusOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    isKeyboardOpened.value = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}
