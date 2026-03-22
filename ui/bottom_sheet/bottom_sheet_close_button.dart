import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';

class BottomSheetCloseButton extends StatelessWidget {
  const BottomSheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FamilyModalSheet.of(context).popPage(),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
        ),
        child: Icon(
          Icons.close,
          size: 18,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
