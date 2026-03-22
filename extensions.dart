import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension IntExtensions on int {
  Duration get seconds {
    return Duration(seconds: this);
  }

  Duration get milliSeconds {
    return Duration(milliseconds: this);
  }
}

Future sleep(Duration duration) async {
  return Future.delayed(duration);
}

extension WidgetExtensions on Widget {
  Widget onTap(Function f) => CupertinoButton(
    pressedOpacity: 0.8,
    padding: const EdgeInsets.all(0),
    onPressed: () => f(),
    child: this,
  );

  Widget borderRadius(double radius) => ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    child: this,
  );

  Widget marginAll(double margin) => Container(margin: EdgeInsets.all(margin), child: this);

  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) => Container(
    margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
    child: this,
  );

  Widget paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);

  Widget marginOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Container(
    margin: EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
    child: this,
  );
}

extension FirstWhereExt<T> on List<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension EmailValidator on String {
  bool isNotAValidEmail() {
    return !RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }
}

extension RowExtensions on Row {
  void withVerticalDivider() {
    final childrenWithDividers = <Widget>[];
    this.children.forEach(
      (child) {
        final i = this.children.indexOf(child);
        childrenWithDividers.insert(
          i,
          Expanded(
            child: Row(
              children: [
                Spacer(),
                child,
                Spacer(),
                if (i < this.children.length - 1)
                  SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      color: Colors.black12,
                      thickness: 0.9,
                      width: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    this.children.clear();
    this.children.addAll(childrenWithDividers);
  }
}

extension DateTimeExtensions on List<DateTime> {
  bool areSameDay(DateTime one, DateTime two) {
    return one.day == two.day && one.month == two.month && one.year == two.year;
  }

  bool containsDate(DateTime compareTo) {
    try {
      final dateTime = this.firstWhereOrNull((date) => areSameDay(date, compareTo));
      return dateTime != null;
    } catch (e) {
      // date  not found
      return false;
    }
  }
}

extension StringExtension on String {
  String capitalizeByWord() {
    return split(' ').map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}').join(' ');
  }

  String capitilizeFirst() {
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}

extension NavigationExtension on Widget {
  Future navigate(
    BuildContext context, {
    Function? callback,
    bool fullscreenDialog = false,
    bool rootNavigator = false,
  }) async {
    return await Navigator.of(context, rootNavigator: rootNavigator)
        .push(
          MaterialPageRoute(
            fullscreenDialog: fullscreenDialog,
            builder: (context) => this,
          ),
        )
        .then((a) {
          if (callback != null) callback(a);
        });
  }

  Future dialog(BuildContext context, {VoidCallback? callback}) async {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return this;
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: Dismissible(
            direction: DismissDirection.vertical,
            key: UniqueKey(),
            onDismissed: (_) => Navigator.of(context).pop(),
            child: child,
          ),
        );
      },

      // PageRouteBuilder(
      //   pageBuilder: (context, anin1, anin2) => this,
      //   fullscreenDialog: true,
      //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //     const begin = Offset(1, 0.0);
      //     const end = Offset.zero;
      //     const curve = Curves.ease;

      //     var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      //     return SlideTransition(
      //       position: animation.drive(tween),
      //       child: child,
      //     );
      //   },
      // ),
    ).then((_) {
      if (callback != null) callback();
    });
  }
}
