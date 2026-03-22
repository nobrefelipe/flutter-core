import 'package:flutter/material.dart';

enum UIKSnackBarType { success, error, notification }

Future UIKShowSnackBar(
  BuildContext context, {
  required String message,
  UIKSnackBarType type = UIKSnackBarType.notification,
}) async {
  Color bgColor = Colors.black;

  if (type == UIKSnackBarType.success) {
    bgColor = Colors.green;
  }
  if (type == UIKSnackBarType.error) {
    bgColor = Colors.red;
  }
  if (type == UIKSnackBarType.notification) {
    bgColor = Colors.blue;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.none,
      content: Text(message),
      behavior: SnackBarBehavior.fixed,
      showCloseIcon: true,
      duration: Duration(seconds: 6),
      elevation: 10,
      // margin: EdgeInsets.only(bottom: 0, right: 0, left: 0),
      backgroundColor: bgColor,
    ),
  );
}
