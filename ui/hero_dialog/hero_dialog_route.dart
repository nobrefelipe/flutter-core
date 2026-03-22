import 'package:flutter/material.dart';

/// {@template hero_dialog_route}
/// Custom [PageRoute] that creates an overlay dialog (popup effect).
///
/// Best used with a [Hero] animation.
/// {@endtemplate}
class HeroDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}

  HeroDialogRoute({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) : _builder = builder,
       _barrierDismissible = barrierDismissible,
       super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;

  final bool _barrierDismissible;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // Disable page transition animations to prevent underlying page from sliding
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}
