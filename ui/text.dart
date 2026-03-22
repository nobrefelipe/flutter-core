import 'package:flutter/material.dart';
import '_theme.dart';

/// Semantic text widget that pulls styles from your ThemeData extension.
/// Usage:
///   UIKText.h1('Hello')
///   UIKText.body('Some copy', color: Colors.grey)
///   UIKText.small('Fine print', maxLines: 2)
class UIKText extends StatelessWidget {
  final String text;
  final TextStyle Function(ThemeData) _styleGetter;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const UIKText._(
    this.text, {
    super.key,
    required TextStyle Function(ThemeData) styleGetter,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : _styleGetter = styleGetter;

  factory UIKText.pageTitle(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.pageTitleStyle, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.pageSubtitle(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.pageSubtitleStyle, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.h1(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.h1Style, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.h2(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.h2Style, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.h3(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.h3Style, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.h4(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.h4Style, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.h5(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.h5Style, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.h6(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.h6Style, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.body(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.bodyStyle, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  factory UIKText.small(String text, {Key? key, Color? color, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      UIKText._(text, key: key, styleGetter: (t) => t.smallStyle, color: color, textAlign: textAlign, maxLines: maxLines, overflow: overflow);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleGetter(theme);

    return Text(
      text,
      style: color != null ? style.copyWith(color: color) : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}
