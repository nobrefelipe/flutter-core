import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grade_coin/core/ui/_theme.dart';

mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> withLoading(Future<void> Function() callback) async {
    isLoading.value = true;
    try {
      await callback();
      HapticFeedback.heavyImpact();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  Widget loadingWidget(double size) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(backgroundColor: Theme.of(context).onSurfaceColor, strokeWidth: 3, color: Colors.white),
      ),
    );
  }
}
