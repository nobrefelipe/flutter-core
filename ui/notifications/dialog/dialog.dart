import 'package:flutter/material.dart';

import '../../buttons/ui_kit_button.dart';
import '../../text.dart';

Future ShowDialog(
  BuildContext context, {
  required String title,
  String? content,
  Function()? onConfirm,
  Function()? onDeny,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: UIKText.h3(title),
        content: content != null ? Text(content) : null,
        actions: [
          // if (onDeny != null)
          UIKButton.ghost(
            label: "Dismiss",
            onTap: () async {
              Navigator.of(context).pop(false);
              if (onDeny != null) onDeny();
            },
          ),
          if (onConfirm != null)
            UIKButton.ghost(
              label: "Yes",
              onTap: () async {
                Navigator.of(context).pop(true);
                onConfirm();
              },
            ),
        ],
      );
    },
  );
}
